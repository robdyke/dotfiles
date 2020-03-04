The UI latency of modern computers has gotten progressively worse in the last
30 years despite advancement in clock speed and computing power. Worse yet, a
lot of user interfaces actually needlessly add latency by introducing pointless
animations. See <https://danluu.com/input-lag/> for an in-depth investigation,
and <https://news.ycombinator.com/item?id=19443076> for insightful discussion.

The lowest possible latency is a target for my workflow and code in this
repository.  Too many user interfaces waste time on stupid animations or are
just generally slow; working with a setup that is perceptually instantaneous is
very pleasant and makes other systems feel irritating to use. Beyond the
configuration here, here are some other things that _may_ help reduce latency:

## Things that noticeably help
* Use an accelerated terminal such as `kitty` or `alacritty`
* Turn all animations off where possible. For example, Firefox's "cosmetic"
  animations and "smooth" scrolling.
* Profile  and optimise application startup time
* Use a SSD (preferably NVMe m.2 PCI-E based)
* Use a tiling window manager (no 3D nonsense, animations or time spent adjusting windows)
* Adjust keyboard repeat rate to the lowest setting
* Mitigate [Bufferbloat][17]

## Things that may help
* Use a monitor with low latency and high refresh rate. Again, gaming monitors
  are usually optimised for this.
* Use a keyboard with a fast polling rate and minimal debounce time. A lot of
  gaming keyboards such as the Corsair K70 are optimised for this. MX Speed
  switches may also help.
* Use (Mosh shell)[https://mosh.org/]


[17]: https://www.bufferbloat.net/projects/bloat/wiki/What_can_I_do_about_Bufferbloat/
