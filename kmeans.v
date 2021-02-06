module division23(enable, A,B,Res, done);

    input enable;
    input [23:0] A;
    input [23:0] B;
    output reg [13:0] Res;
    output reg done;

    reg [23:0] a1,b1;
    reg [24:0] p1;
    integer i;

    always@ (A or B) begin
        if (enable) begin
            a1 = A;
            b1 = B;
            p1= 0;
            for(i=0;i < 24;i=i+1)    begin
                p1 = {p1[22:0],a1[21]};
                a1[23:1] = a1[22:0];
                p1 = p1-b1;
                if(p1[23] == 1)    begin
                    a1[0] = 0;
                    p1 = p1 + b1;
                end else begin
                    a1[0] = 1;
                end
            end
            Res = a1[13:0];
            done = 1'b1;
        end else begin
            done = 1'b0;
        end

    end

endmodule

module controller (enable, dout, din, adr, ren, wen, clk);

    output [30:0] dout;
    input [30:0] din;
    input [9:0] adr;
    input ren,wen,clk,enable;

    memory RAM(enable, dout, din, adr, ren, wen, clok);

endmodule // controller
module memory(enable, dout, din, adr, ren, wen, clok);
    output reg [30:0] dout;
    input [30:0] din;
    input [9:0] adr;
    input ren,wen,clok,enable;

    reg [30:0]storage[0:1000];

    always @ (posedge clok) begin
        if (enable) begin
            if (adr > 10'd1000) begin
                //do nothing
            end else if (ren == 1'd1 && wen == 1'd0) begin
                dout = storage[adr];
            end else if (ren == 1'd0 && wen == 1'd1) begin
                storage[adr] = din;
            end else begin
                //if ren and wen are the same do nothing
            end
        end

    end
endmodule // memory

module euclidean(data_x,data_y,centroid_x,centroid_y,enable,clk,dis);
    input enable;
    input clk;
    input [13:0] data_x,data_y,centroid_x,centroid_y;
    reg [13:0] diff_x,diff_y;
    wire [27:0] sqr_x,sqr_y;
    output reg [27:0] dis;
    reg [13:0] TEMP_X,TEMP_Y;
    reg [13:0]temp_x, temp_y;

    mymult14 mul_x(diff_x,diff_x,sqr_x);
    mymult14 mul_y(diff_y,diff_y,sqr_y);

    always@(*)
    begin

        temp_x = centroid_x;
        temp_y = centroid_y;
        TEMP_X = data_x;
        TEMP_Y = data_y;


        diff_x = TEMP_X - temp_x;
        diff_y = TEMP_Y - temp_y;

        dis = sqr_x + sqr_y;

       end

endmodule


module mymult14(A,B,AmulB );
input [13:0] A;
input [13:0] B;
output reg [27:0] AmulB;


reg [27:0] R;
reg [13:0] C;
reg [13:0] D;
reg [25:0] Y;   //  used in intermediate steps to store the arithmetic shift left of C
reg [25:0] M;   // used in intermediate steps to do arithmetic left shift of C
integer n;        //  used to arithmetic left shift a particular number number n times
integer k;     // k is used to traverse from 0th bit to the MSB of a particular number
integer i;
always@(*)
begin

    n=1'b0;
    k=1'b0;
    i=1'b0;
    C = A;  // multiplicand
    D = B;   //say multiplier
    Y = {14'b0,A};  // appended 14 0's to get 28 bits length
    M = {14'b0,A};  // just another reg same as the above
    R = 28'd0;              //  final product of multiplicand and multiplier stored in R reg
    for(i=0;i<14;i=i+1) // loop running 14 times
    begin
        if(D[k]==0)         // if the Kth bit of multiplier is 0,first increment n and then take R as R + 28'd0
        begin
            n = n+1;
            R = R + 28'd0;
            k = k+1;
        end
        else if(D[k]==1)    // if Kth bit of multiplier is 1, then the multiplicand is arithmetic left shifted n times and added to R
        begin
            n = n+1;
            Y=M<<<n;
            R = R+ Y;
            k = k+1;
        end
        else if(k==0 && D[k]==1)  // if K==0 and and Kth bit of multiplier is 1 , no n increment here,hence no need of arithmetic left shift and add Y to the R
        begin
            Y=M<<<n;
            R = R+Y;
            k = k+1;
        end
        else if(k==0 && D[k]==0)  // if K==0 and Kth bit of multiplier is 0, then no n increment here,just add the 28 0's to the R
        begin
            R = R + 28'd0;
            k = k+1;
        end
    end

       AmulB = R;
end
endmodule //mymult14

module assign_cluster (enable, clk, cluster_A_x, cluster_A_y, cluster_B_x, cluster_B_y, cluster_C_x, cluster_C_y, cluster_D_x, cluster_D_y, cluster_E_x, cluster_E_y, done);
    input enable, clk;
    input [13:0] cluster_A_x, cluster_A_y, cluster_B_x, cluster_B_y, cluster_C_x, cluster_C_y, cluster_D_x, cluster_D_y, cluster_E_x, cluster_E_y;
    output reg done;

    reg [9:0] address = 10'd0;
    reg rwen = 1'b1;
    reg [30:0] mem_write;
    reg [13:0]temp_X, temp_Y;
    reg [2:0]cluster;
    wire [27:0] disA, disB, disC, disD, disE;
    wire [30:0] mem_read;


    euclidean A_cluster(temp_X,temp_Y,cluster_A_x, cluster_A_y,enable,clk,disA);
    euclidean B_cluster(temp_X,temp_Y,cluster_B_x, cluster_B_y,enable,clk,disB);
    euclidean C_cluster(temp_X,temp_Y,cluster_C_x, cluster_C_y,enable,clk,disC);
    euclidean D_cluster(temp_X,temp_Y,cluster_D_x, cluster_D_y,enable,clk,disD);
    euclidean E_cluster(temp_X,temp_Y,cluster_E_x, cluster_E_y,enable,clk,disE);
    controller asgn_cluster(enable, mem_read, mem_write, address, rwen, ~rwen, clk);
    always @ (posedge clk) begin                                                // find the centroid which is closests and assign that cluster to the point
        if (enable) begin
            temp_X = mem_read[30:17];
            temp_Y = mem_read[16:3];
            cluster = mem_read[2:0];
            if (disA < disB && disA < disC && disA < disD && disA < disE) begin
                cluster = 3'd0;
                mem_write = {temp_X, temp_Y, cluster};
                rwen = 1'b0;
            end else if (disB < disC && disB < disD && disB < disE) begin
                cluster = 3'd1;
                mem_write = {temp_X, temp_Y, cluster};
                rwen = 1'b0;
            end else if (disC < disD && disC < disE) begin
                cluster = 3'd2;
                mem_write = {temp_X, temp_Y, cluster};
                rwen = 1'b0;
            end else if (disD < disE) begin
                cluster = 3'd3;
                mem_write = {temp_X, temp_Y, cluster};
                rwen = 1'b0;
            end else begin
                cluster = 3'd4;
                mem_write = {temp_X, temp_Y, cluster};
                rwen = 1'b0;
            end
            rwen = 1'b1;
            address = address + 10'd1;
            if (address == address == 10'd1001) begin
                done = 1'b1;
            end
        end else begin                                                          // when enable is low we reset
            address = 10'd0;
            done = 1'b0;
        end
    end

endmodule // assign_cluster

module get_sum(enable, clk, A_sum_x, B_sum_x, C_sum_x, D_sum_x, E_sum_x, A_sum_y, B_sum_y, C_sum_y, D_sum_y, E_sum_y, A_count, B_count, C_count, D_count, E_count,addition_done);
    input enable, clk;
    output reg[23:0] A_sum_x = 24'd0, B_sum_x = 24'd0, C_sum_x = 24'd0, D_sum_x = 24'd0, E_sum_x = 24'd0;
    output reg[23:0] A_sum_y = 24'd0, B_sum_y = 24'd0, C_sum_y = 24'd0, D_sum_y = 24'd0, E_sum_y = 24'd0;                            //the sum is 24 bits long to account for overflow.
    output reg[13:0] A_count = 14'd0, B_count = 14'd0, C_count = 14'd0, D_count = 14'd0, E_count = 14'd0;
    output reg addition_done = 1'b0;

    reg [13:0]temp_X, temp_Y;
    reg [2:0]cluster;
    wire [30:0] mem_read;
    reg [9:0] address = 10'd0;
    reg tmp;

    controller g_sum(enable, mem_read, 31'd0, address, 1'b1, 1'b0, clk);
    always @ (mem_read) begin                                                   // this always block will run when mem_read changes
        if (enable) begin
            temp_X = mem_read[30:17];
            temp_Y = mem_read[16:3];
            cluster = mem_read[2:0];
            case (cluster)
                3'd0: begin
                    A_sum_x = A_sum_x + temp_X;
                    A_sum_y = A_sum_y + temp_Y;
                    A_count = A_count + 14'd1;
                end
                3'd1: begin
                    B_sum_x = B_sum_x + temp_X;
                    B_sum_y = B_sum_y + temp_Y;
                    B_count = B_count + 14'd1;
                end
                3'd2: begin
                    C_sum_x = C_sum_x + temp_X;
                    C_sum_y = C_sum_y + temp_Y;
                    C_count = C_count + 14'd1;
                end
                3'd3: begin
                    D_sum_x = D_sum_x + temp_X;
                    D_sum_y = D_sum_y + temp_Y;
                    D_count = D_count + 14'd1;
                end
                3'd4: begin
                    E_sum_x = E_sum_x + temp_X;
                    E_sum_y = E_sum_y + temp_Y;
                    E_count = E_count + 14'd1;
                end
                default: begin
                    tmp = 0;
                end

            endcase
            address = address + 10'd1;
            if (address == 10'd1001) begin
                addition_done = 1'b1;
            end
        end else begin
            addition_done = 1'b0;
        end

    end
endmodule // get_sum

module kmeans (enable, clk);
    input enable, clk;

    wire [13:0] Cluster_A_x = 14'd0, Cluster_A_y = 14'd0, Cluster_B_x = 14'd0, Cluster_B_y = 14'd10000, Cluster_C_x = 14'd10000, Cluster_C_y = 14'd0, Cluster_D_x = 14'd10000, Cluster_D_y = 14'd10000, Cluster_E_x = 14'd5000, Cluster_E_y = 14'd5000;
    reg assign_enable, sum_enable, update_enable, update_done;
    wire upd_clus_dne_Ax,upd_clus_dne_Bx,upd_clus_dne_Cx,upd_clus_dne_Dx,upd_clus_dne_Ex, upd_clus_dne_Ay,upd_clus_dne_By,upd_clus_dne_Cy,upd_clus_dne_Dy,upd_clus_dne_Ey;
    wire [23:0] A_sum_X, B_sum_X, C_sum_X, D_sum_X, E_sum_X, A_sum_Y, B_sum_Y, C_sum_Y, D_sum_Y, E_sum_Y;
    wire [13:0] A_Count, B_Count, C_Count, D_Count, E_Count;
    wire assign_done, sum_done;
    integer i;

    assign_cluster cluster(assign_enable, clk, Cluster_A_x, Cluster_A_y, Cluster_B_x, Cluster_B_y, Cluster_C_x, Cluster_C_y, Cluster_D_x, Cluster_D_y, Cluster_E_x, Cluster_E_y, assign_done);

    get_sum sum(sum_enable, clk, A_sum_X, B_sum_X, C_sum_X, D_sum_X, E_sum_X, A_sum_Y, B_sum_Y, C_sum_Y, D_sum_Y, E_sum_Y, A_Count, B_Count, C_Count, D_Count, E_Count,sum_done);

    division23 update_clusterAx(update_enable, A_sum_X, {10'd0,A_Count}, Cluster_A_x, upd_clus_dne_Ax);
    division23 update_clusterAy(update_enable, A_sum_Y, {10'd0,A_Count}, Cluster_A_y, upd_clus_dne_Ay);
    division23 update_clusterBx(update_enable, B_sum_X, {10'd0,B_Count}, Cluster_B_x, upd_clus_dne_Bx);
    division23 update_clusterBy(update_enable, B_sum_Y, {10'd0,B_Count}, Cluster_B_y, upd_clus_dne_By);
    division23 update_clusterCx(update_enable, C_sum_X, {10'd0,C_Count}, Cluster_C_x, upd_clus_dne_Cx);
    division23 update_clusterCy(update_enable, C_sum_Y, {10'd0,C_Count}, Cluster_C_y, upd_clus_dne_Cy);
    division23 update_clusterDx(update_enable, D_sum_X, {10'd0,D_Count}, Cluster_D_x, upd_clus_dne_Dx);
    division23 update_clusterDy(update_enable, D_sum_Y, {10'd0,D_Count}, Cluster_D_y, upd_clus_dne_Dy);
    division23 update_clusterEx(update_enable, E_sum_X, {10'd0,E_Count}, Cluster_E_x, upd_clus_dne_Ex);
    division23 update_clusterEy(update_enable, E_sum_Y, {10'd0,E_Count}, Cluster_E_y, upd_clus_dne_Ey);

    always @ ( * ) begin                                                        // this always block sets the sequence in wich the modules will work. and resets when enable is low.
        if (enable) begin
            if (assign_done) begin
                assign_enable = 1'b0;
                sum_enable = 1'b1;
            end
            if (sum_done) begin
                sum_enable = 1'b0;
                update_enable = 1'b1;
            end
            if (upd_clus_dne_Ax == 1'b1 && upd_clus_dne_Bx == 1'b1 && upd_clus_dne_Cx == 1'b1 && upd_clus_dne_Dx == 1'b1 && upd_clus_dne_Ex == 1'b1 && upd_clus_dne_Ay == 1'b1 && upd_clus_dne_By == 1'b1 && upd_clus_dne_Cy == 1'b1 && upd_clus_dne_Dy == 1'b1 && upd_clus_dne_Ey == 1'b1) begin
                update_done = 1'b1;
            end
            if(update_done) begin
                update_enable = 1'b0;
            end
        end else begin
            assign_enable = 1'b0;
            sum_enable = 1'b0;
            update_enable = 1'b0;
        end
    end
    always @ ( posedge enable ) begin                                           // when enable goes high assign enable also goes high
        assign_enable = 1'b1;
    end
    always @ ( * ) begin                                                        // in this always block the loop is set such the the secquence of moules work more than once to get more accurate result
        if (enable) begin
            for(i=0;i<10;i=i+1) begin
                if (update_done) begin
                    assign_enable = 1'b1;
                end
            end
        end

    end

endmodule // kmeans
