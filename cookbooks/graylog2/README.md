graylog2 Cookbook
=================
Cookbook for managing Graylog2.

Requirements
------------
#### packages
- `elasticsearch` - graylog2 needs elasticsearch to persist and index log messages.
- `mongodb` - graylog2 needs mongodb to store its configuration.

Attributes
----------
#### graylog2::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['graylog2']['homedir']</tt></td>
    <td>String</td>
    <td>Graylog2 install location</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### graylog2::default

e.g.
Just include `graylog2` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[graylog2]"
  ]
}
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: niranjan_hanumegowda@gap.com
