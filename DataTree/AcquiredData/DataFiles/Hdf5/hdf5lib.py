import numpy as np

# ----------------------------------------------------------------
def h5getstr(fid, name):
    if type(fid) is str:
        fid = h5py.File(fid,'r')

    dsetid      = fid.get(name)
    if not dsetid:
        return ''

    # NOTE: This next step used to be the intuitive
    #       val = dsetid.value
    # Now you get a bizarre warning if you use it:   H5pyDeprecationWarning: dataset.value has been deprecated. Use dataset[()] instead
    # Replacing with the following line will get rid of the annoying warning
    val         = dsetid[()]       # new notation

    valbytes    = val.tostring()
    valstr      = valbytes.decode()

    if type(fid) is str:
        fid.close()

    return valstr
