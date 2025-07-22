//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Tue Jul 22 15:41:22 2025
//Host        : Nagesh running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (M_AXI_0_araddr,
    M_AXI_0_arburst,
    M_AXI_0_arcache,
    M_AXI_0_arlen,
    M_AXI_0_arlock,
    M_AXI_0_arprot,
    M_AXI_0_arqos,
    M_AXI_0_arready,
    M_AXI_0_arregion,
    M_AXI_0_arsize,
    M_AXI_0_arvalid,
    M_AXI_0_awaddr,
    M_AXI_0_awburst,
    M_AXI_0_awcache,
    M_AXI_0_awlen,
    M_AXI_0_awlock,
    M_AXI_0_awprot,
    M_AXI_0_awqos,
    M_AXI_0_awready,
    M_AXI_0_awregion,
    M_AXI_0_awsize,
    M_AXI_0_awvalid,
    M_AXI_0_bready,
    M_AXI_0_bresp,
    M_AXI_0_bvalid,
    M_AXI_0_rdata,
    M_AXI_0_rlast,
    M_AXI_0_rready,
    M_AXI_0_rresp,
    M_AXI_0_rvalid,
    M_AXI_0_wdata,
    M_AXI_0_wlast,
    M_AXI_0_wready,
    M_AXI_0_wstrb,
    M_AXI_0_wvalid,
    S_AXI_0_araddr,
    S_AXI_0_arburst,
    S_AXI_0_arcache,
    S_AXI_0_arlen,
    S_AXI_0_arlock,
    S_AXI_0_arprot,
    S_AXI_0_arqos,
    S_AXI_0_arready,
    S_AXI_0_arregion,
    S_AXI_0_arsize,
    S_AXI_0_arvalid,
    S_AXI_0_awaddr,
    S_AXI_0_awburst,
    S_AXI_0_awcache,
    S_AXI_0_awlen,
    S_AXI_0_awlock,
    S_AXI_0_awprot,
    S_AXI_0_awqos,
    S_AXI_0_awready,
    S_AXI_0_awregion,
    S_AXI_0_awsize,
    S_AXI_0_awvalid,
    S_AXI_0_bready,
    S_AXI_0_bresp,
    S_AXI_0_bvalid,
    S_AXI_0_rdata,
    S_AXI_0_rlast,
    S_AXI_0_rready,
    S_AXI_0_rresp,
    S_AXI_0_rvalid,
    S_AXI_0_wdata,
    S_AXI_0_wlast,
    S_AXI_0_wready,
    S_AXI_0_wstrb,
    S_AXI_0_wvalid,
    aclk_0,
    aresetn_0);
  output [31:0]M_AXI_0_araddr;
  output [1:0]M_AXI_0_arburst;
  output [3:0]M_AXI_0_arcache;
  output [7:0]M_AXI_0_arlen;
  output [0:0]M_AXI_0_arlock;
  output [2:0]M_AXI_0_arprot;
  output [3:0]M_AXI_0_arqos;
  input M_AXI_0_arready;
  output [3:0]M_AXI_0_arregion;
  output [2:0]M_AXI_0_arsize;
  output M_AXI_0_arvalid;
  output [31:0]M_AXI_0_awaddr;
  output [1:0]M_AXI_0_awburst;
  output [3:0]M_AXI_0_awcache;
  output [7:0]M_AXI_0_awlen;
  output [0:0]M_AXI_0_awlock;
  output [2:0]M_AXI_0_awprot;
  output [3:0]M_AXI_0_awqos;
  input M_AXI_0_awready;
  output [3:0]M_AXI_0_awregion;
  output [2:0]M_AXI_0_awsize;
  output M_AXI_0_awvalid;
  output M_AXI_0_bready;
  input [1:0]M_AXI_0_bresp;
  input M_AXI_0_bvalid;
  input [31:0]M_AXI_0_rdata;
  input M_AXI_0_rlast;
  output M_AXI_0_rready;
  input [1:0]M_AXI_0_rresp;
  input M_AXI_0_rvalid;
  output [31:0]M_AXI_0_wdata;
  output M_AXI_0_wlast;
  input M_AXI_0_wready;
  output [3:0]M_AXI_0_wstrb;
  output M_AXI_0_wvalid;
  input [31:0]S_AXI_0_araddr;
  input [1:0]S_AXI_0_arburst;
  input [3:0]S_AXI_0_arcache;
  input [7:0]S_AXI_0_arlen;
  input [0:0]S_AXI_0_arlock;
  input [2:0]S_AXI_0_arprot;
  input [3:0]S_AXI_0_arqos;
  output S_AXI_0_arready;
  input [3:0]S_AXI_0_arregion;
  input [2:0]S_AXI_0_arsize;
  input S_AXI_0_arvalid;
  input [31:0]S_AXI_0_awaddr;
  input [1:0]S_AXI_0_awburst;
  input [3:0]S_AXI_0_awcache;
  input [7:0]S_AXI_0_awlen;
  input [0:0]S_AXI_0_awlock;
  input [2:0]S_AXI_0_awprot;
  input [3:0]S_AXI_0_awqos;
  output S_AXI_0_awready;
  input [3:0]S_AXI_0_awregion;
  input [2:0]S_AXI_0_awsize;
  input S_AXI_0_awvalid;
  input S_AXI_0_bready;
  output [1:0]S_AXI_0_bresp;
  output S_AXI_0_bvalid;
  output [31:0]S_AXI_0_rdata;
  output S_AXI_0_rlast;
  input S_AXI_0_rready;
  output [1:0]S_AXI_0_rresp;
  output S_AXI_0_rvalid;
  input [31:0]S_AXI_0_wdata;
  input S_AXI_0_wlast;
  output S_AXI_0_wready;
  input [3:0]S_AXI_0_wstrb;
  input S_AXI_0_wvalid;
  input aclk_0;
  input aresetn_0;

  wire [31:0]M_AXI_0_araddr;
  wire [1:0]M_AXI_0_arburst;
  wire [3:0]M_AXI_0_arcache;
  wire [7:0]M_AXI_0_arlen;
  wire [0:0]M_AXI_0_arlock;
  wire [2:0]M_AXI_0_arprot;
  wire [3:0]M_AXI_0_arqos;
  wire M_AXI_0_arready;
  wire [3:0]M_AXI_0_arregion;
  wire [2:0]M_AXI_0_arsize;
  wire M_AXI_0_arvalid;
  wire [31:0]M_AXI_0_awaddr;
  wire [1:0]M_AXI_0_awburst;
  wire [3:0]M_AXI_0_awcache;
  wire [7:0]M_AXI_0_awlen;
  wire [0:0]M_AXI_0_awlock;
  wire [2:0]M_AXI_0_awprot;
  wire [3:0]M_AXI_0_awqos;
  wire M_AXI_0_awready;
  wire [3:0]M_AXI_0_awregion;
  wire [2:0]M_AXI_0_awsize;
  wire M_AXI_0_awvalid;
  wire M_AXI_0_bready;
  wire [1:0]M_AXI_0_bresp;
  wire M_AXI_0_bvalid;
  wire [31:0]M_AXI_0_rdata;
  wire M_AXI_0_rlast;
  wire M_AXI_0_rready;
  wire [1:0]M_AXI_0_rresp;
  wire M_AXI_0_rvalid;
  wire [31:0]M_AXI_0_wdata;
  wire M_AXI_0_wlast;
  wire M_AXI_0_wready;
  wire [3:0]M_AXI_0_wstrb;
  wire M_AXI_0_wvalid;
  wire [31:0]S_AXI_0_araddr;
  wire [1:0]S_AXI_0_arburst;
  wire [3:0]S_AXI_0_arcache;
  wire [7:0]S_AXI_0_arlen;
  wire [0:0]S_AXI_0_arlock;
  wire [2:0]S_AXI_0_arprot;
  wire [3:0]S_AXI_0_arqos;
  wire S_AXI_0_arready;
  wire [3:0]S_AXI_0_arregion;
  wire [2:0]S_AXI_0_arsize;
  wire S_AXI_0_arvalid;
  wire [31:0]S_AXI_0_awaddr;
  wire [1:0]S_AXI_0_awburst;
  wire [3:0]S_AXI_0_awcache;
  wire [7:0]S_AXI_0_awlen;
  wire [0:0]S_AXI_0_awlock;
  wire [2:0]S_AXI_0_awprot;
  wire [3:0]S_AXI_0_awqos;
  wire S_AXI_0_awready;
  wire [3:0]S_AXI_0_awregion;
  wire [2:0]S_AXI_0_awsize;
  wire S_AXI_0_awvalid;
  wire S_AXI_0_bready;
  wire [1:0]S_AXI_0_bresp;
  wire S_AXI_0_bvalid;
  wire [31:0]S_AXI_0_rdata;
  wire S_AXI_0_rlast;
  wire S_AXI_0_rready;
  wire [1:0]S_AXI_0_rresp;
  wire S_AXI_0_rvalid;
  wire [31:0]S_AXI_0_wdata;
  wire S_AXI_0_wlast;
  wire S_AXI_0_wready;
  wire [3:0]S_AXI_0_wstrb;
  wire S_AXI_0_wvalid;
  wire aclk_0;
  wire aresetn_0;

  design_1 design_1_i
       (.M_AXI_0_araddr(M_AXI_0_araddr),
        .M_AXI_0_arburst(M_AXI_0_arburst),
        .M_AXI_0_arcache(M_AXI_0_arcache),
        .M_AXI_0_arlen(M_AXI_0_arlen),
        .M_AXI_0_arlock(M_AXI_0_arlock),
        .M_AXI_0_arprot(M_AXI_0_arprot),
        .M_AXI_0_arqos(M_AXI_0_arqos),
        .M_AXI_0_arready(M_AXI_0_arready),
        .M_AXI_0_arregion(M_AXI_0_arregion),
        .M_AXI_0_arsize(M_AXI_0_arsize),
        .M_AXI_0_arvalid(M_AXI_0_arvalid),
        .M_AXI_0_awaddr(M_AXI_0_awaddr),
        .M_AXI_0_awburst(M_AXI_0_awburst),
        .M_AXI_0_awcache(M_AXI_0_awcache),
        .M_AXI_0_awlen(M_AXI_0_awlen),
        .M_AXI_0_awlock(M_AXI_0_awlock),
        .M_AXI_0_awprot(M_AXI_0_awprot),
        .M_AXI_0_awqos(M_AXI_0_awqos),
        .M_AXI_0_awready(M_AXI_0_awready),
        .M_AXI_0_awregion(M_AXI_0_awregion),
        .M_AXI_0_awsize(M_AXI_0_awsize),
        .M_AXI_0_awvalid(M_AXI_0_awvalid),
        .M_AXI_0_bready(M_AXI_0_bready),
        .M_AXI_0_bresp(M_AXI_0_bresp),
        .M_AXI_0_bvalid(M_AXI_0_bvalid),
        .M_AXI_0_rdata(M_AXI_0_rdata),
        .M_AXI_0_rlast(M_AXI_0_rlast),
        .M_AXI_0_rready(M_AXI_0_rready),
        .M_AXI_0_rresp(M_AXI_0_rresp),
        .M_AXI_0_rvalid(M_AXI_0_rvalid),
        .M_AXI_0_wdata(M_AXI_0_wdata),
        .M_AXI_0_wlast(M_AXI_0_wlast),
        .M_AXI_0_wready(M_AXI_0_wready),
        .M_AXI_0_wstrb(M_AXI_0_wstrb),
        .M_AXI_0_wvalid(M_AXI_0_wvalid),
        .S_AXI_0_araddr(S_AXI_0_araddr),
        .S_AXI_0_arburst(S_AXI_0_arburst),
        .S_AXI_0_arcache(S_AXI_0_arcache),
        .S_AXI_0_arlen(S_AXI_0_arlen),
        .S_AXI_0_arlock(S_AXI_0_arlock),
        .S_AXI_0_arprot(S_AXI_0_arprot),
        .S_AXI_0_arqos(S_AXI_0_arqos),
        .S_AXI_0_arready(S_AXI_0_arready),
        .S_AXI_0_arregion(S_AXI_0_arregion),
        .S_AXI_0_arsize(S_AXI_0_arsize),
        .S_AXI_0_arvalid(S_AXI_0_arvalid),
        .S_AXI_0_awaddr(S_AXI_0_awaddr),
        .S_AXI_0_awburst(S_AXI_0_awburst),
        .S_AXI_0_awcache(S_AXI_0_awcache),
        .S_AXI_0_awlen(S_AXI_0_awlen),
        .S_AXI_0_awlock(S_AXI_0_awlock),
        .S_AXI_0_awprot(S_AXI_0_awprot),
        .S_AXI_0_awqos(S_AXI_0_awqos),
        .S_AXI_0_awready(S_AXI_0_awready),
        .S_AXI_0_awregion(S_AXI_0_awregion),
        .S_AXI_0_awsize(S_AXI_0_awsize),
        .S_AXI_0_awvalid(S_AXI_0_awvalid),
        .S_AXI_0_bready(S_AXI_0_bready),
        .S_AXI_0_bresp(S_AXI_0_bresp),
        .S_AXI_0_bvalid(S_AXI_0_bvalid),
        .S_AXI_0_rdata(S_AXI_0_rdata),
        .S_AXI_0_rlast(S_AXI_0_rlast),
        .S_AXI_0_rready(S_AXI_0_rready),
        .S_AXI_0_rresp(S_AXI_0_rresp),
        .S_AXI_0_rvalid(S_AXI_0_rvalid),
        .S_AXI_0_wdata(S_AXI_0_wdata),
        .S_AXI_0_wlast(S_AXI_0_wlast),
        .S_AXI_0_wready(S_AXI_0_wready),
        .S_AXI_0_wstrb(S_AXI_0_wstrb),
        .S_AXI_0_wvalid(S_AXI_0_wvalid),
        .aclk_0(aclk_0),
        .aresetn_0(aresetn_0));
endmodule
