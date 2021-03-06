class Glibmm < Formula
  desc "C++ interface to glib"
  homepage "https://www.gtkmm.org/"
  url "https://download.gnome.org/sources/glibmm/2.58/glibmm-2.58.0.tar.xz"
  sha256 "d34189237b99e88228e6f557f7d6e62f767fe356f395a244f5ad0e486254b645"

  bottle do
    cellar :any
    sha256 "367935fed103058ab13149602dae4240d4be0716c002903393dd598ea8b37b0e" => :mojave
    sha256 "10fabb2143c1b8333738b90b283f7619b6e4aa70f5cd7f06f704e2bdc21d9668" => :high_sierra
    sha256 "38f36fb0615c809b605a3611124334679bb166a2c56c31535636ed28f8a4063f" => :sierra
    sha256 "732cef730a8a93450d225f2813175a326517285329f5eb2fd6ddc37adf8b78f9" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "libsigc++"

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j6" if ENV["CIRCLECI"]

    ENV.cxx11

    # see https://bugzilla.gnome.org/show_bug.cgi?id=781947
    # Note that desktopappinfo.h is not installed on Linux
    # if these changes are made.
    if OS.mac?
      inreplace "gio/giomm/Makefile.in" do |s|
        s.gsub! "OS_COCOA_TRUE", "OS_COCOA_TEMP"
        s.gsub! "OS_COCOA_FALSE", "OS_COCOA_TRUE"
        s.gsub! "OS_COCOA_TEMP", "OS_COCOA_FALSE"
      end
    end

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <glibmm.h>

      int main(int argc, char *argv[])
      {
         Glib::ustring my_string("testing");
         return 0;
      }
    EOS
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    libsigcxx = Formula["libsigc++"]
    flags = %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/glibmm-2.4
      -I#{libsigcxx.opt_include}/sigc++-2.0
      -I#{libsigcxx.opt_lib}/sigc++-2.0/include
      -I#{lib}/glibmm-2.4/include
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{libsigcxx.opt_lib}
      -L#{lib}
      -lglib-2.0
      -lglibmm-2.4
      -lgobject-2.0
      -lsigc-2.0
    ]
    flags << "-lintl" if OS.mac?
    system ENV.cxx, "-std=c++11", "test.cpp", "-o", "test", *flags
    system "./test"
  end
end
