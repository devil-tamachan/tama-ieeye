
doc = MQSystem.getDocument()
for o in doc.object:
  if o == None:
    continue
  idxObj = doc.getObjectIndex(o)
  for f in o.face:
    idxFace = o.getFaceIndexFromUniqueID(f.id)
    
    if doc.isSelectFace(idxObj, idxFace):
      for vii in range(f.numVertex):
         vi = f.index[vii]
         doc.addSelectVertex(idxObj, vi)
      continue
    
    if f.numVertex<2:
      continue
    
    for vii in range(f.numVertex):
      if doc.isSelectLine(idxObj, idxFace, vii)==1:
        vi = f.index[vii]
        doc.addSelectVertex(idxObj, vi)
        #MQSystem.println("obj: "+str(idxObj)+", face: "+str(idxFace)+", vidx: "+str(vi))
        if vii==f.numVertex-1:
          vi = f.index[0]
          doc.addSelectVertex(idxObj, vi)
          #MQSystem.println("obj: "+str(idxObj)+", face: "+str(idxFace)+", vidx: "+str(vi))
        else:
          vi = f.index[vii+1]
          doc.addSelectVertex(idxObj, vi)
          #MQSystem.println("obj: "+str(idxObj)+", face: "+str(idxFace)+", vidx: "+str(vi))
        #MQSystem.println("")