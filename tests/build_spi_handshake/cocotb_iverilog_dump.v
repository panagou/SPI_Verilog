module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("C:\\Users\\Stathis\\Desktop\\test\\vlsi_tests\\spi\\tests\\build_spi_handshake\\spi_handshake_top.fst");
    end
    $dumpvars(0, spi_handshake_top);
end
endmodule
