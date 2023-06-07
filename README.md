# rubuild
Build c projects with gcc using a Ruby script.

## Run example:

```console
cd example/
chmod +x ./example.sh
```

## Visualize dependency graph
Using method `Rubuild::output_dot_file(target_name, output_path)`, a .dot file can be generated to visualize dependencies in the project with Graphviz.
### Example:
![Image](./example/graph.png)