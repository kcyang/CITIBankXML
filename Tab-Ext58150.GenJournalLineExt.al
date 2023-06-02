tableextension 58150 "Gen. Journal Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(55100; "XML Export Completion"; Boolean)
        {
            CaptionML = ENU = 'XML Export Completion', JPN = '文書のエクスポート完了';
            DataClassification = CustomerContent;
        }
        field(55101; "Bank Transfer Type"; Enum "Bank Transfer Type")
        {
            CaptionML = ENU = 'Bank Transfer Type', JPN = '銀行振込の種類';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("Vendor Bank Account"."Bank Transfer Type"
                where(Code = field("Recipient Bank Account"), "Vendor No." = field("Account No.")));
        }
    }
}
