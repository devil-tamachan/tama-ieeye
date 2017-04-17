def setX0(v):
  p1 = v.getPos()
  p1.x = 0
  v.setPos(p1)


doc = MQSystem.getDocument()
for o in doc.object:
  if o == None:
    continue
  idxObj = doc.getObjectIndex(o)
  for f in o.face:
    idxFace = o.getFaceIndexFromUniqueID(f.id)
    if f.numVertex<2:
      continue
    
    for li in range(f.numVertex):
      vi = f.index[li]
      if doc.isSelectVertex(idxObj, vi)==1:
        v = o.vertex[vi]
        setX0(v)
        MQSystem.println("obj: "+str(idxObj)+", vidx: "+str(vi))
      if doc.isSelectLine(idxObj, idxFace, li)==1:
        vi = f.index[li]
        doc.addSelectVertex(idxObj, vi)
        v = o.vertex[vi]
        setX0(v)
        MQSystem.println("obj: "+str(idxObj)+", face: "+str(idxFace)+", vidx: "+str(vi))
        if li==f.numVertex-1:
          vi = f.index[0]
          doc.addSelectVertex(idxObj, vi)
          v = o.vertex[vi]
          setX0(v)
          MQSystem.println("obj: "+str(idxObj)+", face: "+str(idxFace)+", vidx: "+str(vi))
        else:
          vi = f.index[li+1]
          doc.addSelectVertex(idxObj, vi)
          v = o.vertex[vi]
          setX0(v)
          MQSystem.println("obj: "+str(idxObj)+", face: "+str(idxFace)+", vidx: "+str(vi))
        MQSystem.println("")