class Urls {
  // ── Local backend (Flask on this machine, port 8080) ──────────────────────
  //
  // Android emulator  → 10.0.2.2 maps to the host PC's localhost
  // iOS Simulator     → localhost or 127.0.0.1 works directly
  // Physical device   → replace with your PC's LAN IP, e.g. 192.168.1.x
  //
  static String Url = "http://172.25.94.124:8080";
}
