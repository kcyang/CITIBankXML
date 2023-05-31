enum 58150 "Bank Account Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; FUTSUU)
    {
        CaptionML = ENU = 'FUTSUU', JPN = '普通';
    }
    value(2; "TOUZA")
    {
        CaptionML = ENU = 'TOUZA', JPN = '当座';
    }
    value(3; CHOCHIKU)
    {
        CaptionML = ENU = 'CHOCHIKU', JPN = '貯蓄';
    }
    value(4; SONOTA)
    {
        CaptionML = ENU = 'SONOTA', JPN = 'その他';
    }
}
