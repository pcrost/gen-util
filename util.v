package util;

    typedef struct packed {
        bit clk;
        bit rst;
    } Gcr;

    function integer log2(integer n);
        integer v;
        integer ret;
        v = n;
        ret = 0;
        while (v > 1) begin
            ret = ret + 1;
            v = v / 2;
        end
        return ret;
    endfunction

    function count_ones(integer a, integer len);
        integer ret;
        ret = 0;
        for (integer i = 0; i < len; i++) begin
            if (a & (1 << i)) begin
                ret = ret + 1;
            end
        end
        return ret;
    endfunction

endpackage
