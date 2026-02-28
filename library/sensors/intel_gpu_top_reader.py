import subprocess
import glob
import time
from library.log import logger

class IntelGPUTopReader:
    def __init__(self):
        self.proc = None
        self._start_proc()

    def _start_proc(self):
        try:
            if self.proc:
                try:
                    self.proc.terminate()
                    self.proc.wait(timeout=0.2)
                except:
                    pass
            
            self.proc = subprocess.Popen(
                ["sudo", "intel_gpu_top", "-l", "-s", "1000"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                bufsize=1
            )
        except Exception:
            self.proc = None

    def _get_temp(self):
        zones = glob.glob("/sys/class/thermal/thermal_zone*/type")
        for zone in zones:
            try:
                with open(zone, "r") as f:
                    t = f.read().strip()
                if "x86_pkg_temp" in t or "Package id 0" in t:
                    temp_path = zone.replace("type", "temp")
                    with open(temp_path, "r") as tf:
                        return int(tf.read().strip()) / 1000
            except:
                pass
        return None

    def get_info(self):
        if not self.proc or self.proc.poll() is not None:
            self._start_proc()
        
        if not self.proc:
            return None

        try:
            for _ in range(10):
                line = self.proc.stdout.readline()
                if not line:
                    return None
                
                parts = line.split()
                if len(parts) >= 9 and parts[0].isdigit():
                    try:
                        gpu_clock = float(parts[1])
                        gpu_busy = float(parts[8])
                        gpu_temp = self._get_temp()

                        return {
                            "usage": gpu_busy,
                            "clock": gpu_clock,
                            "temperature": gpu_temp
                        }
                    except (ValueError, IndexError):
                        continue
        except Exception:
            pass
            
        return None
