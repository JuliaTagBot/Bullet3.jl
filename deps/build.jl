using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libBullet3Dynamics"], :libdynamics),
    LibraryProduct(prefix, String["libBulletSoftBody"], :libsoftbody),
    LibraryProduct(prefix, String["libBullet3Collision"], :libcollision),
    #LibraryProduct(prefix, String["libBulletRobotics"], :librobotics),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/SimonDanisch/Bullet3Builder/releases/download/2.87"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/bullet3.v2.87.0.aarch64-linux-gnu.tar.gz", "943d8607b91ddaad622ed44d1537385adb63b473f770f2754a75edffbc4ae642"),
    Linux(:aarch64, :musl) => ("$bin_prefix/bullet3.v2.87.0.aarch64-linux-musl.tar.gz", "53badc8fff615ae093c875013b065e942e8f15332508713d1bc7e2d3f1105bf4"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/bullet3.v2.87.0.arm-linux-gnueabihf.tar.gz", "c59b6addce7470d85168bcacaa829af61e49c0c4034dfc3607b581752accf74f"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/bullet3.v2.87.0.arm-linux-musleabihf.tar.gz", "fcac8e31de8976130283e0fbca9971df6cba9ea5550877b95a4fcb0b10de7996"),
    Linux(:i686, :glibc) => ("$bin_prefix/bullet3.v2.87.0.i686-linux-gnu.tar.gz", "863cc3168f4701275d3546c0c6674598fe4a8172d83422757ccf2083075beabd"),
    Linux(:i686, :musl) => ("$bin_prefix/bullet3.v2.87.0.i686-linux-musl.tar.gz", "cb7381d167c636e350a71e891770b19de749a35ef2c63a8714d70f80c862100b"),
    Windows(:i686) => ("$bin_prefix/bullet3.v2.87.0.i686-w64-mingw32.tar.gz", "542d2d6d8f695b791bd8f0365c9f9d12022d5b8e1571528fbe25afa4b5a7e106"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/bullet3.v2.87.0.powerpc64le-linux-gnu.tar.gz", "c914c1acf35466cb2c03fadd3d5aa40bc993326fa67801ab61bf4734c426bc65"),
    MacOS(:x86_64) => ("$bin_prefix/bullet3.v2.87.0.x86_64-apple-darwin14.tar.gz", "c3233ea810f6ca84edc018dd7880df23a4b975215597b8fec09c09d7b201b3d2"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/bullet3.v2.87.0.x86_64-linux-gnu.tar.gz", "415b583677a9a487b409ad738a7132aaee93a3f91f43753cc14f6d700b2ce741"),
    Linux(:x86_64, :musl) => ("$bin_prefix/bullet3.v2.87.0.x86_64-linux-musl.tar.gz", "1e26a5f967bcbd8dd5113982a06a09742b09524ec9421cf481f324ddf6c12153"),
    Windows(:x86_64) => ("$bin_prefix/bullet3.v2.87.0.x86_64-w64-mingw32.tar.gz", "668c92c8cf76f746227a8db935863a16646affc9b71f8a9bc2a95cf2d004345b"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
