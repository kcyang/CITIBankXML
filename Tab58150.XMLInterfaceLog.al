table 55100 "XML Interface Log"
{
    Caption = 'XML Interface Log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Entry; BigInteger)
        {
            Caption = 'Entry';
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; "XML Name"; Text[65])
        {
            Caption = 'XML Name';
            DataClassification = ToBeClassified;
        }
        field(3; "Extract Date"; Date)
        {
            Caption = 'Extract Date';
            DataClassification = ToBeClassified;
        }
        field(4; Path; Text[30])
        {
            Caption = 'Path';
            DataClassification = ToBeClassified;
        }
        field(5; "XML File"; Blob)
        {
            Caption = 'XML File';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Entry)
        {
            Clustered = true;
        }
    }
}
