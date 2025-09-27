// tb_audio_effects_sine.v
`timescale 1ns/1ps

module tb_audio_effects_sine;

  // Clock 100 MHz (chu kỳ 10 ns)
  reg clk = 1'b0;
  always #5 clk = ~clk;

  // Tín hiệu điều khiển lấy mẫu
  reg  sample_end = 1'b0;
  reg  sample_req = 1'b0;

  // Giao tiếp audio
  wire [15:0] audio_output;
  reg  [15:0] audio_input = 16'd0;

  // control[0]=SINE=1, control[1]=FEEDBACK=0
  reg [3:0] control = 4'b0001;

  // Ghi file CSV các mẫu xuất ra
  integer fd;
  integer n;

  // DUT: audio_effects
  audio_effects dut (
      .clk(clk),
      .sample_end(sample_end),
      .sample_req(sample_req),
      .audio_output(audio_output),
      .audio_input(audio_input),
      .control(control)
  );

  // Phát một xung 1 chu kỳ clock
  task pulse(input bit for_req, input bit for_end);
    begin
      sample_req <= for_req;
      sample_end <= for_end;
      @(posedge clk);
      sample_req <= 1'b0;
      sample_end <= 1'b0;
    end
  endtask

  initial begin
    // Dump waveform (xem với GTKWave)
    $dumpfile("tb_audio_effects_sine.vcd");
    $dumpvars(0, tb_audio_effects_sine);

    // Mở file CSV
    fd = $fopen("sine_samples.csv", "w");
    if (fd == 0) begin
      $display("ERROR: Khong mo duoc file sine_samples.csv");
      $finish;
    end
    $fwrite(fd, "sample_idx,audio_output_hex,audio_output_dec\n");

    // Đợi ổn định
    repeat (5) @(posedge clk);

    // Phát ~120 mẫu (đủ đi hết ROM 0..99 và vòng lại)
    for (n = 0; n < 120; n = n + 1) begin
      // (tùy chọn) cập nhật last_sample mỗi mẫu; ở chế độ SINE không cần nhưng an toàn
      pulse(1'b0, 1'b1);   // sample_end=1 trong 1 chu kỳ
      pulse(1'b1, 1'b0);   // sample_req=1 trong 1 chu kỳ -> DUT xuất mẫu sin

      // Ghi mẫu ngay sau khi sample_req được chấp nhận
      // (audio_output đã được cập nhật trong chu kỳ sample_req)
      $fwrite(fd, "%0d,0x%04h,%0d\n", n, audio_output, $signed(audio_output));

      // Giãn cách giữa các mẫu cho dễ xem (không bắt buộc)
      repeat (3) @(posedge clk);
    end

    $fclose(fd);
    $display("Hoan tat: da ghi %0d mau vao sine_samples.csv", n);
    #50;
    $finish;
  end

endmodule
