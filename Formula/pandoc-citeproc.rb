require "language/haskell"

class PandocCiteproc < Formula
  include Language::Haskell::Cabal

  desc "Library and executable for using citeproc with pandoc"
  homepage "https://github.com/jgm/pandoc-citeproc"
  url "https://hackage.haskell.org/package/pandoc-citeproc-0.16.1.2/pandoc-citeproc-0.16.1.2.tar.gz"
  sha256 "4f1fd1285611aa11aadb73ad74437b4dfb6b5bce72144eb45313ca9a27f89a94"
  head "https://github.com/jgm/pandoc-citeproc.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    sha256 "42081a52bcc12fbd04f5c211e1bc8afa25aa0462c1b84feb1c632901b91624be" => :mojave
    sha256 "c1b246624a48029bb4a2e06623f29bfe6e55d9a9b99e7609128c9c18fe1c0aad" => :high_sierra
    sha256 "52e8e1ffb36b25c3c1ee39d0a38a1225b439da78bf0468cf51a2907af3161c2b" => :sierra
    sha256 "2a6dde16b963000cb7b414df79a14dcc60c91ef572f378424812c88907e7199d" => :x86_64_linux
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "pandoc"
  depends_on "unzip" => :build unless OS.mac?

  def install
    install_cabal_package
  end

  test do
    (testpath/"test.bib").write <<~EOS
      @Book{item1,
      author="John Doe",
      title="First Book",
      year="2005",
      address="Cambridge",
      publisher="Cambridge University Press"
      }
    EOS
    expected = <<~EOS
      ---
      references:
      - id: item1
        type: book
        author:
        - family: Doe
          given: John
        issued:
        - year: 2005
        title: First book
        publisher: Cambridge University Press
        publisher-place: Cambridge
      ...
    EOS
    assert_equal expected, shell_output("#{bin}/pandoc-citeproc -y test.bib")
  end
end
