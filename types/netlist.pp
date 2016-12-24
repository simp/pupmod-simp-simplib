# Matches all possible lists of Network Addresses and Hostnames
type Simplib::Netlist = Array[Variant[Simplib::Host, Simplib::Host::Port, Simplib::IP::V4::CIDR, Simplib::IP::V4::DDQ]]
