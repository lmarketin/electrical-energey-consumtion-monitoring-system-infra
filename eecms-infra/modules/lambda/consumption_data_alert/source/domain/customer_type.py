from enum import Enum

class CustomerType(Enum):
    HH  = "house_hold"
    HHP = "house_hold_with_parameters"
    I   = "industrial"
    C   = "commercial"
    P   = "public"

    @staticmethod
    def get_types_that_require_parameters():
        return {CustomerType.HHP.name, CustomerType.I.name, CustomerType.C.name, CustomerType.P.name}