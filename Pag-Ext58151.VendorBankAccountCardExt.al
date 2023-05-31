pageextension 58151 VendorBankAccountCardExt extends "Vendor Bank Account Card"
{
    layout
    {
        addlast(General)
        {
            field("Bank Transfer Type"; Rec."Bank Transfer Type")
            {
                ApplicationArea = All;
            }
            field("Bank Account Type"; Rec."Bank Account Type")
            {
                ApplicationArea = All;
            }
        }
    }
}
