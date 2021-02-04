module division(A,B,Res, enable);

    input [13:0] A;
    input [13:0] B;
    inout enable;
    output [13:0] Res;

    reg [13:0] Res = 0;
    reg [13:0] a1,b1;
    reg [14:0] p1;
    integer i;

    always@ (*)
    begin

        a1 = A;
        b1 = B;
        p1= 0;
        for(i=0;i < 14;i=i+1)    begin
            p1 = {p1[12:0],a1[14]};
            a1[13:1] = a1[12:0];
            p1 = p1-b1;
            if(p1[13] == 1)    begin
                a1[0] = 0;
                p1 = p1 + b1;   end
            else
                a1[0] = 1;
        end
        Res = a1;
    end
endmodule

module memory(dout, din, adr, ren, wen, clk);
    output [30:0] dout;
    input [30:0] din;
    input [9:0] adr;
    input ren,wen,clk;

    reg [30:0]storage[0:1000]

    always @ (posedge clk) begin
        if (adr > 10'd1000) begin
            //do nothing
        end else if (ren == 1'd1 && wen == 1'd0) begin
            dout = storage[adr]
        end else if (ren == 1'd0 && wen == 1'd1) begin
            storage[adr] = din
        end else begin
            //if ren and wen are the same do nothing
        end
    end
endmodule
module euclidean (x,y,......);

endmodule // euclidean
module assign_cluster (enable, clk);
    input enable, clk;

    reg [9:0] address = 10'd0;
    reg rwen = 1'b1;
    reg [30:0] mem_read, mem_write;
    reg [13:0]temp_X, temp_Y;
    reg [2:0]cluster;
    ref [] disA, disB, disC, disD, disE;

    euclidean A()
    euclidean B()
    euclidean C()
    euclidean D()
    euclidean E()
    memory a_cluster(mem_read, mem_write, address, rwen, ~rwen, clk);
    always @ (posedge clk) begin
    //if enable
        temp_X = mem_read[30:17];
        temp_Y = mem_read[16:3];
        cluster = mem_read[2:0];
        if (disA > disB && disA > disC && disA > disD && disA > disE) begin
            cluster = 3'd0;
            mem_write = {temp_X, temp_Y, cluster};
            rwen = 1'b0
        end else if (disB > disC && disB > disD && disB > disE) begin
            cluster = 3'd1;
            mem_write = {temp_X, temp_Y, cluster};
            rwen = 1'b0
        end else if (disC > disD && disC > disE) begin
            cluster = 3'd2;
            mem_write = {temp_X, temp_Y, cluster};
            rwen = 1'b0
        end else if (disD > disE) begin
            cluster = 3'd3;
            mem_write = {temp_X, temp_Y, cluster};
            rwen = 1'b0
        end else begin
            cluster = 3'd4;
            mem_write = {temp_X, temp_Y, cluster};
            rwen = 1'b0
        end
        rwen = 1'b1
        address = address + 10'd1


    end

endmodule // assign_cluster

module get_sum(enable, clk, A_sum_x, B_sum_x, C_sum_x, D_sum_x, E_sum_x, A_sum_y, B_sum_y, C_sum_y, D_sum_y, E_sum_y, A_count, B_count, C_count, D_count, E_count,addition_done);
    input enable;
    output reg[23:0] A_sum_x = 24'd0, B_sum_x = 24'd0, C_sum_x = 24'd0, D_sum_x = 24'd0, E_sum_x = 24'd0;
    output reg[23:0] A_sum_y = 24'd0, B_sum_y = 24'd0, C_sum_y = 24'd0, D_sum_y = 24'd0, E_sum_y = 24'd0;                            //the sum is 24 bits long to account for overflow.
    output reg[13:0] A_count = 14'd0, B_count = 14'd0, C_count = 14'd0, D_count = 14'd0, E_count = 14'd0;
    output reg addition_done = 1'b0;

    reg [13:0]temp_X, temp_Y;
    reg [2:0]cluster;
    reg [30:0] mem_read;
    reg [9:0] address = 10'd0;

    memory g_sum(mem_read, 31'd0, address, 1'b1, 1'b0, clk);
    always @ (mem_read) begin                                                   // this always block will run when mem_read changes
    // if enable
        temp_X = mem_read[30:17];
        temp_Y = mem_read[16:3];
        cluster = mem_read[2:0];
        case (cluster)
            3'd0: begin
                    A_sum_x = A_sum_x + temp_X;
                    A_sum_y = A_sum_y + temp_Y;
                    A_count = A_count + 14'd1
                end
            3'd1: begin
                    B_sum_x = B_sum_x + temp_X;
                    B_sum_y = B_sum_y + temp_Y;
                    B_count = B_count + 14'd1
                end ;
            3'd2: begin
                    C_sum_x = C_sum_x + temp_X;
                    C_sum_y = C_sum_y + temp_Y;
                    C_count = C_count + 14'd1
                end ;
            3'd3: begin
                    D_sum_x = D_sum_x + temp_X;
                    D_sum_y = D_sum_y + temp_Y;
                    D_count = D_count + 14'd1
                end ;
            3'd4: begin
                    E_sum_x = E_sum_x + temp_X;
                    E_sum_y = E_sum_y + temp_Y;
                    E_count = E_count + 14'd1
                end ;
            default: ;//invalid cluster;
            address = address + 10'd1;
            if (address == 10'd1001) begin
                addition_done = 1'b1
            end
        endcase

    end
endmodule
