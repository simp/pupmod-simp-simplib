# Valid systemd service names
type Simplib::Systemd::ServiceName = Pattern['^([A-za-z0-9.:_\\-]){1,256}$']
