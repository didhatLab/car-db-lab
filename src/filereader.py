import pathlib
from typing import Iterable
from src.utilis import list2sqlclass


class FileReader:

    def __init__(self, endpoint, end_signal=None, point_for_signal=None, signal=None,
                 data_class_for_converting=None):
        self._endpoint = endpoint
        self.point_for_signal = point_for_signal
        self.signal = signal
        self._end_signal = end_signal
        self.dataclass_for_converting = data_class_for_converting
        self._is_signal_sent = False

    def _send_maybe_signal(self, line: str):
        if self.point_for_signal is not None and line == self.point_for_signal:
            self._is_signal_sent = True
            yield self.signal
            return

        self._is_signal_sent = False
        return

    def read_generator_file(self, file_path: str):
        with pathlib.Path(file_path).open(mode="r") as f:
            line = f.readline().replace("\n", "")
            while line != self._endpoint:
                yield from self._send_maybe_signal(line)
                if not self._is_signal_sent:
                    values = line.split()
                    obj = list2sqlclass(values, self.dataclass_for_converting)
                    yield obj
                line = f.readline().replace("\n", "")
        yield self._end_signal
        return
