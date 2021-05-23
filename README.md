# PNGUtil

This project was built from [stumpy_png](https://github.com/stumpycr/stumpy_png) and [stumpy_core](https://github.com/stumpycr/stumpy_core).
Many thanks to [@l3kn](https://github.com/l3kn) for all the work you did!

## Usage

### Install the `png_util` shard

1. `shards init`
2. Add the dependency to the `shard.yml` file
 ``` yaml
 ...
 dependencies:
   png_util:
     github: matthewmcgarvey/png_util
 ...
 ```
3. `shards install`

### Resize Image

``` crystal
require "png_util"

canvas = PNGUtil.read("foo.png")
canvas.resize(120, 120)
PNGUtil.write(canvas, "resized-foo.png")
```

## Troubleshooting

If you run into errors like

```bash
/usr/bin/ld: cannot find -lz
collect2: error: ld returned 1 exit status
```

make sure `zlib` is installed
([Installing zlib under ubuntu](https://ubuntuforums.org/showthread.php?t=1528204)).
