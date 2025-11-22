import lxml.etree as ET

dom = ET.parse('Cerved.xml')
xslt = ET.parse('Cerved.xsl')
transform = ET.XSLT(xslt)
newdom = transform(dom)
with open('Cerved.html', 'wb') as f:
    f.write(ET.tostring(newdom, pretty_print=True))
print("Transformation complete. Cerved.html created.")
