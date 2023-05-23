pageextension 58150 PaymentJournalExt extends "Payment Journal"
{
    layout
    {
        addfirst(Control1)
        {
            field("XML Export Completion"; Rec."XML Export Completion")
            {
                Editable = false;
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast("F&unctions")
        {
            action(BankXMLExport)
            {
                Caption = 'Bank XML Export';
                Image = CreateXMLFile;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    IF COMPANYNAME = 'Guerbet Japan KK' THEN BEGIN

                        GVRE_GenJournalLine.RESET;
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name", 'PAYMENTS');
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name", 'CITI');
                        GVRE_GenJournalLine.SETFILTER(GVRE_GenJournalLine.Comment, '%1', '<>53_ROPE');
                        IF GVRE_GenJournalLine.FIND('-') THEN BEGIN
                            GVRE_GenJournalLine.SETFILTER(GVRE_GenJournalLine.Comment, '%1', '<>53_ROPT');
                            IF GVRE_GenJournalLine.FIND('-') THEN BEGIN
                                ERROR('There are empty or wrong values in comment fields. Please check the comment field in CITI batch');
                            END;
                        END;

                        GVTX_Options := 'OPEX, International OPEX';
                        GVTX_OptionsMessage := 'Choose one of the following options';
                        GVIN_OptionNumber := DIALOG.STRMENU(GVTX_Options, 1, GVTX_OptionsMessage);

                        GVCU_BankXML.GVFN_ExportData(GVIN_OptionNumber);
                        CLEAR(GVCU_BankXML);
                    END;
                end;
            }
            action(XMLUncheck)
            {
                Caption = 'Uncheck XML Item';
                Image = DeleteXML;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    IF (Rec."Journal Template Name" = 'PAYMENTS') AND (Rec."Journal Batch Name" = 'CITI') THEN BEGIN
                        GVTX_Options := 'OPEX, International OPEX, Check';
                        GVTX_OptionsMessage := 'Choose one of the following options to uncheck';
                        GVIN_OptionNumber := DIALOG.STRMENU(GVTX_Options, 1, GVTX_OptionsMessage);

                        IF GVIN_OptionNumber <> 3 THEN BEGIN
                            GVCU_BankXML.GVFN_UncheckXML(GVIN_OptionNumber);
                            CLEAR(GVCU_BankXML);
                        END ELSE BEGIN
                            GVRE_GenJournalLine.RESET;
                            CurrPage.SETSELECTIONFILTER(GVRE_GenJournalLine);
                            IF GVRE_GenJournalLine.FIND('-') THEN BEGIN
                                REPEAT
                                    IF (GVRE_GenJournalLine.Comment <> '53_ROPE') AND (GVRE_GenJournalLine.Comment <> '53_ROPT') THEN BEGIN
                                        GVRE_GenJournalLine."XML Export Completion" := TRUE;
                                        GVRE_GenJournalLine.MODIFY;
                                    END;
                                UNTIL GVRE_GenJournalLine.NEXT = 0;
                            END;

                        END;
                    END;
                end;
            }
        }
    }


    var
        GVCU_BankXML: Codeunit BankXML;
        GVTX_Options: Text;
        GVTX_OptionsMessage: Text;
        GVIN_OptionNumber: Integer;
        Text002: TextConst ENU = 'There are lines that not XML exported.';
        GVRE_GenJournalLine: Record "Gen. Journal Line";
}
