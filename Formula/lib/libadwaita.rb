class Libadwaita < Formula
  desc "Building blocks for modern adaptive GNOME applications"
  homepage "https://gnome.pages.gitlab.gnome.org/libadwaita/"
  url "https://download.gnome.org/sources/libadwaita/1.6/libadwaita-1.6.1.tar.xz"
  sha256 "d00ac845a4545d92e6805e31095a51c68f9f4e02426900472084b0cddce3f833"
  license "LGPL-2.1-or-later"

  # libadwaita doesn't use GNOME's "even-numbered minor is stable" version
  # scheme. This regex is the same as the one generated by the `Gnome` strategy
  # but it's necessary to avoid the related version scheme logic.
  livecheck do
    url :stable
    regex(/libadwaita-(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_sequoia: "1d7006aa3789eca08befd2e8b718fcdd6b2bc8e84517b98a96b3009b28cfb0d9"
    sha256 arm64_sonoma:  "a1f7e51680efa242eaf4404fc05b63231bf3dd6311ac71f7d9fc51e456b2fffa"
    sha256 arm64_ventura: "fb19cb2f7c9f74427cac742140a03d217e5c0d6aae28f36b6355b594e8963188"
    sha256 sonoma:        "82e00b8a68ceb393c444a2a439075fa857640e21542149628e43ab43e64e828f"
    sha256 ventura:       "9d670362807fdbe6e4d30b750d43f9594072a62ce267c2ab7ae6505e17bc6137"
    sha256 x86_64_linux:  "207077b66478916431a4b1029b0a72b8f6d7509464b8e3da3da26f569902f559"
  end

  depends_on "gettext" => :build
  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on "vala" => :build

  depends_on "appstream"
  depends_on "fribidi"
  depends_on "glib"
  depends_on "graphene"
  depends_on "gtk4"
  depends_on "pango"

  uses_from_macos "python" => :build

  on_macos do
    depends_on "gettext"
  end

  def install
    system "meson", "setup", "build", "-Dtests=false", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <adwaita.h>

      int main(int argc, char *argv[]) {
        g_autoptr (AdwApplication) app = NULL;
        app = adw_application_new ("org.example.Hello", G_APPLICATION_DEFAULT_FLAGS);
        return g_application_run (G_APPLICATION (app), argc, argv);
      }
    C
    flags = shell_output("#{Formula["pkg-config"].opt_bin}/pkg-config --cflags --libs libadwaita-1").strip.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test", "--help"

    # include a version check for the pkg-config files
    assert_match version.to_s, (lib/"pkgconfig/libadwaita-1.pc").read
  end
end
