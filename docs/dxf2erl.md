<h1>Custom widgets</h1>

To help create new widgets there is a small program in util to convert DXF-files to erlang tv drawing primitives. Download or draw your own graphics in a CAD system and save as DXF. Convert the DXF file with dxf2erl:start("filename.dxf"). from the erlang console. There is a sample DXF file in util as well as a demo widget made up from the clock.dxf file. You can even load the clock.dxf file into a CAD system and change, scale and rotate the graphics and save it into a new DXF file.

1. Mirror your drawing in the CAD-app down over the X-axis (Y=0)
2. Move the drawing up to it's previous position (up above the X-axis)
3. Save as DXF
4. Undo Move and Miror


The DXF file can be created in QCAD (free) http://www.ribbonsoft.com/en/ , AUTOCAD, Google Sketchup Pro and other CAD systems. Entities with higher thickness will be drawn last. Closed polylines will be filled areas in tv.
