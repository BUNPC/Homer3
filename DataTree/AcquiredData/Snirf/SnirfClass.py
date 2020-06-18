import os
import sys
import h5py
import numpy as np
import glob


# Local imports
rootpath = os.path.dirname(os.path.abspath(__file__)) + '/../'
sys.path.append(rootpath)
from DataFiles.Hdf5.hdf5lib import h5getstr


# ---------------------------------------------------------------------------
def PrintArraySize(v, vname):
    if len(v.shape)==1:
        nrows = v.shape[0]
        ncols = 1
    elif len(v.shape)==2:
        nrows = v.shape[0]
        ncols = v.shape[1]
    sys.stdout.write('%s = [%d x %d]\n'% (vname, nrows, ncols))




############################################################
class ErrorClass:
    # -----------------------------------------------------------
    def __init__(self):
        self.err = 0
        if self.IsEmpty():
            self.err = -1

    # -----------------------------------------------------------
    def GetError(self):
        return self.err

    # -----------------------------------------------------------
    def IsEmpty(self):
        return False



############################################################
class DataClass(ErrorClass):

    # -----------------------------------------------------------
    def __init__(self, fid, location):
        self.dataTimeSeries = np.array([])
        self.time = np.array([])
        try:
            self.dataTimeSeries = np.array(fid.get(location + '/dataTimeSeries'))
            self.time = np.array(fid.get(location + '/time'))
        except:
            self.err = -1
            return

        ErrorClass.__init__(self)


    # -----------------------------------------------------------
    def IsEmpty(self):
        if ((self.time.all()==None) or (len(self.time)==0)) and \
            ((self.dataTimeSeries.all()==None) or (len(self.dataTimeSeries)==0)):
            return True
        return False

    # -----------------------------------------------------------
    def Print(self):
        PrintArraySize(self.dataTimeSeries, '  dataTimeSeries')
        PrintArraySize(self.time, '  time')


############################################################
class ProbeClass(ErrorClass):

    # -----------------------------------------------------------
    def __init__(self, fid, location):

        self.wavelengths          = np.array(fid.get(location + '/wavelengths'))
        self.wavelengthsEmission  = fid.get(location + '/wavelengthsEmission')
        self.sourcePos2D  = np.array(fid.get(location + '/sourcePos2D'))
        self.detectorPos2D  = np.array(fid.get(location + '/detectorPos2D'))
        self.frequencies  = np.array(fid.get(location + '/frequencies'))
        self.timeDelay  = 0
        self.timeDelayWidth  = 0
        self.momentOrder = []
        self.correlationTimeDelay = 0
        self.correlationTimeDelayWidth = 0
        self.sourceLabels = np.array(fid.get(location + '/sourceLabels'))
        self.detectorLabels = np.array(fid.get(location + '/detectorLabels'))

        ErrorClass.__init__(self)


    # -----------------------------------------------------------
    def Print(self):
        sys.stdout.write('  wavelengths = %s\n'% self.wavelengths)
        sys.stdout.write('  wavelengthsEmission = %s\n'% self.wavelengthsEmission)
        sys.stdout.write('  sourcePos2D:\n')
        for ii in range(0, self.sourcePos2D.shape[0]):
            sys.stdout.write('      %s\n'% self.sourcePos2D[ii])
        sys.stdout.write('  detectorPos2D:\n')
        for ii in range(0, self.detectorPos2D.shape[0]):
            sys.stdout.write('      %s\n'% self.detectorPos2D[ii])
        sys.stdout.write('  frequencies = %s\n'% self.frequencies)
        sys.stdout.write('  timeDelay = %s\n'% self.timeDelay)
        sys.stdout.write('  timeDelayWidth = %s\n'% self.timeDelayWidth)
        sys.stdout.write('  momentOrder = %s\n'% self.momentOrder)
        sys.stdout.write('  correlationTimeDelay = %s\n'% self.correlationTimeDelay)
        sys.stdout.write('  correlationTimeDelayWidth = %s\n'% self.correlationTimeDelayWidth)
        sys.stdout.write('  sourceLabels = %s\n'% self.sourceLabels)
        sys.stdout.write('  detectorLabels = %s\n'% self.detectorLabels)




############################################################
class StimClass(ErrorClass):

    # -----------------------------------------------------------
    def __init__(self, fid, location):
        self.name  = h5getstr(fid, location + '/name')
        self.data  = np.array(fid.get(location + '/data'))
        ErrorClass.__init__(self)

    # -----------------------------------------------------------
    def Print(self):
        sys.stdout.write('  name: %s\n'% self.name)
        sys.stdout.write('  data:\n')
        for ii in range(0, self.data.shape[0]):
            sys.stdout.write('      %s\n'% self.data[ii])

    # -----------------------------------------------------------
    def IsEmpty(self):
        if not self.name:
            return True
        if (self.data.all()==None) or (len(self.data)==0):
            return True
        return False



###########################################################
class AuxClass(ErrorClass):

    # -----------------------------------------------------------
    def __init__(self, fid, location):
        self.name  = h5getstr(fid, location + '/name')
        self.time  = np.array(fid.get(location + '/time'))
        self.dataTimeSeries  = np.array(fid.get(location + '/dataTimeSeries'))
        ErrorClass.__init__(self)

    # -----------------------------------------------------------
    def Print(self):
        sys.stdout.write('  name: %s\n'% self.name)
        PrintArraySize(self.dataTimeSeries, '  dataTimeSeries')
        PrintArraySize(self.time, '  time')

    # -----------------------------------------------------------
    def IsEmpty(self):
        if ((self.time.all()==None) or (len(self.time)==0)) and \
            ((self.dataTimeSeries.all()==None) or (len(self.dataTimeSeries)==0)):
            return True
        return False



############################################################
class MetaDataTagsClass(ErrorClass):

    # -----------------------------------------------------------
    def __init__(self, fid, location):
        self.SubjectID = h5getstr(fid, location + '/SubjectID')
        self.MeasurementDate = h5getstr(fid, location + '/MeasurementDate')
        self.MeasurementTime = h5getstr(fid, location + '/MeasurementTime')
        self.LengthUnit = h5getstr(fid, location + '/LengthUnit')
        self.TimeUnit = h5getstr(fid, location + '/TimeUnit')
        ErrorClass.__init__(self)

    # -----------------------------------------------------------
    def Print(self):
        sys.stdout.write('  SubjectID: %s\n'% self.SubjectID)
        sys.stdout.write('  MeasurementDate: %s\n'% self.MeasurementDate)
        sys.stdout.write('  MeasurementTime: %s\n'% self.MeasurementTime)
        sys.stdout.write('  LengthUnit: %s\n'% self.LengthUnit)
        sys.stdout.write('  TimeUnit: %s\n'% self.TimeUnit)


############################################################
class SnirfClass(ErrorClass):

    # -----------------------------------------------------------
    def __init__(self, fname):
        fid = h5py.File(fname,'r')

        # formatVersion
        self.formatVersion = h5getstr(fid, 'formatVersion')

        # metaDataTags
        self.metaDataTags = MetaDataTagsClass(fid, '/nirs/metaDataTags')

        # data
        self.data = []
        ii = 1
        while 1:
            temp = DataClass(fid, '/nirs/data' + str(ii))
            if temp.GetError() < 0:
                break
            self.data.append(temp)
            ii = ii+1

        # stim
        self.stim = []
        ii = 1
        while 1:
            temp = StimClass(fid, '/nirs/stim' + str(ii))
            if temp.GetError() < 0:
                break
            self.stim.append(temp)
            ii = ii+1

        # probe
        self.probe = ProbeClass(fid, '/nirs/probe')

        # aux
        self.aux = []
        ii = 1
        while 1:
            temp = AuxClass(fid, '/nirs/aux' + str(ii))
            if temp.GetError() < 0:
                break
            self.aux.append(temp)
            ii = ii+1

        fid.close()

        ErrorClass.__init__(self)


    # -----------------------------------------------------------
    def Print(self):
        sys.stdout.write('formatVersion = %s\n'% self.formatVersion)
        sys.stdout.write('metaDataTags:\n')
        self.metaDataTags.Print()

        for ii in range(0, len(self.data)):
            sys.stdout.write('data[%d]:\n'% ii)
            self.data[ii].Print()

        for ii in range(0, len(self.stim)):
            sys.stdout.write('stim[%d]:\n'% ii)
            self.stim[ii].Print()

        sys.stdout.write('probe:\n')
        self.probe.Print()

        for ii in range(0, len(self.aux)):
            sys.stdout.write('aux[%d]:\n'% ii)
            self.aux[ii].Print()


# -----------------------------------------------------------
if __name__ == "__main__":
    if len(sys.argv) > 1:
        filenames[0] =  sys.argv[1]
    else:
        # filenames = glob.glob('../../../../snirf-samples/basic/*.snirf')
        filenames = glob.glob('./Examples/*.snirf')

    for ii in range(0, len(filenames)):
        sys.stdout.write('======================================================================\n')
        sys.stdout.write('Loading data from %s\n\n'% filenames[ii])
        snirf = SnirfClass(filenames[ii])
        snirf.Print()
        sys.stdout.write('\n')
