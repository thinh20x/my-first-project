#!/usr/bin/env python3
"""
gen_luts.py
Sinh 2 file LUT 16-bit signed, 256 mẫu/chu kỳ:
 - sine_lut.hex  : 256 mẫu sine, full-scale (signed 16-bit)
 - ecg_lut.hex   : 256 mẫu mô phỏng ECG (P-QRS-T đơn giản)
Mỗi dòng là 4 hex digits (no 0x prefix), suitable for $readmemh in Verilog.
"""
import numpy as np

N = 256
MAX16 = 32767
MIN16 = -32768

def to_hex16_signed(x):
    """Chuyển integer signed 16-bit sang 4-digit hex (two's complement)"""
    x = int(np.round(x))
    if x < 0:
        x = (1 << 16) + x
    return f"{x:04x}"

def gen_sine(amplitude=0.95):
    # amplitude fraction of full-scale
    xs = []
    for i in range(N):
        v = amplitude * MAX16 * np.sin(2.0 * np.pi * i / N)
        xs.append(to_hex16_signed(v))
    return xs

def gen_ecg(peak=1.0):
    # Một ECG đơn giản: baseline + small P, QRS (sharp spike), T wave
    # Sử dụng tổng của gaussian để mô phỏng dạng P-QRS-T trong 256 mẫu
    t = np.linspace(0, 1, N, endpoint=False)
    # positions (as fraction of cycle)
    p_pos = 0.2
    qrs_pos = 0.5
    t_pos = 0.65
    # widths
    p_w = 0.025
    qrs_w = 0.01
    t_w = 0.05
    # amplitudes (relative)
    p_a = 0.1
    qrs_a = 1.0
    t_a = 0.35
    baseline = 0.0

    gauss = lambda x, mu, sigma, A: A * np.exp(-0.5 * ((x-mu)/sigma)**2)
    signal = baseline + gauss(t, p_pos, p_w, p_a) \
                   - gauss(t, qrs_pos - 0.007, qrs_w*0.6, 0.15) \
                   + gauss(t, qrs_pos, qrs_w, qrs_a) \
                   - gauss(t, qrs_pos + 0.006, qrs_w*0.6, 0.12) \
                   + gauss(t, t_pos, t_w, t_a)
    # normalize to fit signed 16-bit
    signal = signal - np.mean(signal)
    signal = signal / np.max(np.abs(signal))  # scale to +/-1
    signal = signal * (0.95 * MAX16 * peak)
    return [to_hex16_signed(v) for v in signal]

def write_file(fname, lines):
    with open(fname, "w") as f:
        for l in lines:
            f.write(l + "\n")
    print(f"Wrote {len(lines)} lines to {fname}")

if __name__ == "__main__":
    sine = gen_sine(amplitude=0.95)
    ecg = gen_ecg(peak=0.95)
    write_file("sine_lut.hex", sine)
    write_file("ecg_lut.hex", ecg)
    print("Done. Files: sine_lut.hex, ecg_lut.hex")
