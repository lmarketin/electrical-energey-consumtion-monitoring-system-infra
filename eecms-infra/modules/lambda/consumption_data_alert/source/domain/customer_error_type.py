from enum import Enum

class CustomerErrorType(Enum):
    MCD = "Missing consumption data error"
    MNP = "Missing network parameters error"