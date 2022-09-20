function convertMeasListOrder2dotNirs()
DeleteDataFiles(pwd, 'nirs')
Snirf2Nirs
DeleteDataFiles(pwd, 'snirf')
Nirs2Snirf
