# Matches all possible lists of Network Addresses and Hostnames
type Simplib::Netlist = Array[Variant[Simplib::Host, Simplib::IP::V4::CIDR, Simplib::IP::V4::DDQ, Simplib::IP::V4::Port, Simplib::IP::V6::CIDR, Simplib::IP::V6::Port]]
