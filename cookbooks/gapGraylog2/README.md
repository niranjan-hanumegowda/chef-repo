gapGraylog2 Cookbook
====================
Wrapper cookbook for Graylog2; Workarounds for Gap-specific implementation

Requirements
------------
#### packages
- `graylog2` - gapGraylog2 needs graylog2.

Attributes
----------
None

Usage
-----
#### gapGraylog2::default
e.g.
Just include `gapGraylog2` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[gapGraylog2]"
  ]
}
```

License and Authors
-------------------
Authors: niranjan_hanumegowda@gap.com
