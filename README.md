# gridfw-compiler
Compile sources files for gridfw



# Compile views

By default, The the framework supports "pug" files
```javascript
// use default options
compiler.views()
```

To support an other engine, add the code that will compile each file mapped by the file extension.
Example:
```javascript
// use default options
compiler.views({
    engines: {
        // fileExtension: function(content, options){}
        pug: function(content, options){
            // compile content
            content = Pug.compileClient(content, {
                pretty: options.pretty,
                filename: options.filename,
                name: 'template' // result function name
            });
            // export data
            return content + "\nmodule.exports = template";
        },
        ejs: function(content, options){
            // compile content
            content = EJS.compile({
                pretty: options.pretty,
                filename: options.filename,
                client: true, // render client function
            });
            // export data
            return "module.exports = " + content.toString();
        }
    }
})
```