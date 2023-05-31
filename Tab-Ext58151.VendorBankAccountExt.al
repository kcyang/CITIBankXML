tableextension 58151 VendorBankAccountExt extends "Vendor Bank Account"
{
    fields
    {
        field(58150; "Bank Account Type"; Enum "Bank Account Type")
        {
            Caption = 'Bank Account Type';
            DataClassification = CustomerContent;
        }
        field(58151; "Bank Transfer Type"; Enum "Bank Transfer Type")
        {
            Caption = 'Bank Transfer Type';
            DataClassification = CustomerContent;
        }
    }
}
