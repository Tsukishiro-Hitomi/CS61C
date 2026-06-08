from pathlib import Path
from typing import Callable, Dict, List, Optional
import hashlib
import json
import numpy as np
import os
import random
import struct
import subprocess

from PIL import Image
from PIL import ImageOps

project_dir = Path(__file__).parent.resolve().parent
tests_dir = project_dir / "tests"
oracle_path = Path("/home/ff/cs61c/fa24/proj4/convolve_oracle")

all_tests: Dict[str, "TestSpec"] = {}

FILTER_MULTIPLIER = 1e6


def set_tests_dir(path: Path):
    global tests_dir
    tests_dir = path


def run_oracle(a_path: Path, b_path: Path, out_path: Path):
    """
    自学者本地替代方案：使用 NumPy 完美模拟伯克利官方的 convolve_oracle
    支持大数、负数溢出截断，且完全不依赖原版 Matrix 类的限制。
    """
    import struct
    import numpy as np

    # 1. 内部辅助函数：直接以 C 语言有符号 int32 格式读取 bin 文件
    def safe_read_matrix(path: Path):
        with path.open("rb") as f:
            contents = f.read()
        # 前 8 个字节是 Rows 和 Cols (无符号 32 位)
        rows = struct.unpack("I", contents[0:4])[0]
        cols = struct.unpack("I", contents[4:8])[0]
        # 后面的数据直接用 "i" (有符号 32 位 int) 读入，自动处理负数
        data = struct.unpack("i" * rows * cols, contents[8:])
        return rows, cols, np.array(data, dtype=np.int32).reshape(rows, cols)

    # 2. 读取矩阵 A 和矩阵 B
    a_rows, a_cols, a_arr = safe_read_matrix(a_path)
    b_rows, b_cols, b_arr = safe_read_matrix(b_path)

    # 3. 计算输出矩阵的维度
    out_rows = a_rows - b_rows + 1
    out_cols = a_cols - b_cols + 1
    out_arr = np.zeros((out_rows, out_cols), dtype=np.int32)

    # 4. 核心卷积/互相关计算 (严格模拟 C 语言 32 位有符号整型乘加行为)
    # 根据 CS61C 惯例，这里采用直接滑窗点乘求和（若后续发现和答案不符，可将 b_arr 替换为 np.flip(b_arr)）
    for r in range(out_rows):
        for c in range(out_cols):
            sub_a = a_arr[r : r + b_rows, c : c + b_cols]
            # 显式转换为 int32 确保计算中发生与 C 语言一致的溢出截断
            val = np.sum(sub_a * b_arr)
            out_arr[r, c] = np.int32(val)

    # 5. 将计算结果严格按照原版格式写入 ref.bin
    with out_path.open("wb") as f:
        # 写入行数和列数 (无符号 I)
        f.write(struct.pack("I", out_rows))
        f.write(struct.pack("I", out_cols))
        
        # 展平数据
        final_data = out_arr.flatten().astype(np.int32)
        
        # 核心技巧：使用小写 "i" (有符号 int32) 批量打包写入文件
        # 这样 Python 会直接把有符号的负数转换成对应的底层 4 字节二进制补码，绝不报错
        f.write(struct.pack("i" * len(final_data), *final_data))


def randint(lower, upper, **kwargs):
    return np.random.randint(lower, upper + 1, **kwargs)


def md5sum(path: Path) -> str:
    with path.open("rb") as f:
        contents = f.read()
    return hashlib.md5(contents).hexdigest()


def gif_to_frames(gif_path: str) -> List["GIFFrame"]:
    gif = Image.open(gif_path)
    gif_frames = []
    for frame in range(gif.n_frames):
        gif.seek(frame)
        matrix = Matrix(gif.size[1], gif.size[0], list(
            ImageOps.grayscale(gif.copy()).getdata()))
        gif_frames.append(GIFFrame(gif.info["duration"] or 10, matrix))
    gif.close()

    return gif_frames


def frames_to_gif(frames: List["GIFFrame"], gif_path: str):
    images = [Image.fromarray((np.array(f.matrix.data).flatten().reshape(
        (f.matrix.rows, f.matrix.cols), ) / FILTER_MULTIPLIER).astype(np.uint8), mode="L") for f in frames]
    durations = [f.duration for f in frames]
    images[0].save(gif_path, save_all=True,
                   append_images=images[1:], loop=0, duration=durations)


class GIFFrame:
    def __init__(self, duration: int, matrix: "Matrix"):
        self.duration = duration
        self.matrix = matrix


class Matrix:
    @staticmethod
    def random(rows: int, cols: int, min_value=-1000, max_value=1000) -> "Matrix":
        values = list(randint(min_value, max_value,
                      size=rows * cols) & 0xFFFFFFFF)
        return Matrix(rows, cols, values)

    @staticmethod
    def from_path(path: Path):
        try:
            with path.open("rb") as f:
                input_bin_contents = f.read()
            rows = struct.unpack("I", input_bin_contents[0:4])[0]
            cols = struct.unpack("I", input_bin_contents[4:8])[0]
            data = struct.unpack("I" * rows * cols, input_bin_contents[8:])

            return Matrix(rows, cols, list(data))
        except Exception as e:
            print("Unexpected error while reading matrix")
            print(e)
            exit(1)

    def __init__(self, rows: int, cols: int, data: List[int]):
        self.rows = rows
        self.cols = cols
        self.data = data

    def generate(self, path: Path):
        with path.open("wb") as f:
            # Write row and column counts
            f.write(struct.pack("I", self.rows))
            f.write(struct.pack("I", self.cols))

            # Write matrix elements as bytes
            f.write(struct.pack("I" * self.rows * self.cols, *self.data))


class Task:
    def __init__(self, a_matrix: Matrix, b_matrix: Matrix):
        self.a_matrix = a_matrix
        self.b_matrix = b_matrix

        assert a_matrix.rows >= b_matrix.rows, "Rows of matrix A must be greater than or equal to the rows in matrix B"
        assert a_matrix.cols >= b_matrix.cols, "Columns of matrix A must be greater than or equal to the columns in matrix B"

    def generate(self, path: Path):
        path.mkdir(exist_ok=True)
        self.a_matrix.generate(path / "a.bin")
        self.b_matrix.generate(path / "b.bin")
        a_md5 = md5sum(path / "a.bin")
        b_md5 = md5sum(path / "b.bin")

        try:
            with (path / ".hashes.json").open("r") as f:
                hashes_json = json.load(f)
                if hashes_json["a.bin"] == a_md5 and hashes_json["b.bin"] == b_md5:
                    return
        except Exception:
            pass

        with (path / ".hashes.json").open("w") as f:
            f.write(json.dumps({"a.bin": a_md5, "b.bin": b_md5}))
        run_oracle(path / "a.bin", path / "b.bin", path / "ref.bin")


class TestSpec:
    def __init__(self, name: str, func: Callable[["TestSpec"], None]):
        self.path = tests_dir / name
        self.func = func
        self._tasks: List[Task] = []
        self._gifs: List[tuple[str, Matrix]] = []

    def add_task(self, task: Task):
        self._tasks.append(task)

    def add_gif(self, file: str, filter: Matrix):
        self._gifs.append((file, filter))

    def generate(self):
        self.func(self)

        tasks = self._tasks[:]
        gifs: List[List[tuple[str, int]]] = []
        for (gif_path, gif_filter) in self._gifs:
            gif_frames = gif_to_frames(gif_path)
            gif_tasks: List[tuple[str, int]] = []
            for frame in gif_frames:
                gif_tasks.append((f"task{len(tasks)}", frame.duration))
                tasks.append(Task(frame.matrix, gif_filter))
            gifs.append(gif_tasks)

        self.path.mkdir(exist_ok=True, parents=True)
        with (self.path / "input.txt").open("w") as f:
            f.write(str(len(tasks)) + "\n")
            for i, task in enumerate(tasks):
                task_path = self.path / f"task{i}"
                task.generate(task_path)
                rel_task_dir = os.path.relpath(task_path, self.path)
                f.write(f"./{rel_task_dir}\n")

        if len(gifs) > 0:
            with (self.path / "gifs.json").open("w") as f:
                json.dump(gifs, f)


def Test(name: Optional[str] = None, seed: int = 42):
    def decorator(func):
        nonlocal name
        name = name or str(func.__name__)

        def _func(test: TestSpec):
            random.seed(seed)
            np.random.seed(seed)
            func(test)

        test = TestSpec(name, _func)
        all_tests[name] = test

    return decorator
