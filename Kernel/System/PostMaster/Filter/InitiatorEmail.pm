package Kernel::System::PostMaster::Filter::InitiatorEmail;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Ticket',
    'Kernel::System::DynamicField',
    'Kernel::Config',
);

sub new {
    my ( $Type, %Param ) = @_;
    return bless {}, $Type;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $LogObject          = $Kernel::OM->Get('Kernel::System::Log');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    # Получаем настройки из SysConfig
    my $Senders      = $ConfigObject->Get('PostMaster::PreFilterModule###InitiatorEmail::Senders') || '';
    my $Regex        = $ConfigObject->Get('PostMaster::PreFilterModule###InitiatorEmail::Regex')
        || '^Email:\s*([A-Za-z0-9._%+-]+\@[A-Za-z0-9.-]+\.[A-Za-z]{2,})';
    my $DynamicField = $ConfigObject->Get('PostMaster::PreFilterModule###InitiatorEmail::DynamicField')
        || 'InitiatorEmail';

    my @SenderList = split /\s*,\s*/, $Senders;

    # Проверяем отправителя
    my $From = $Param{GetParam}->{From} || '';
    return 1 if !grep { lc $_ eq lc $From } @SenderList;

    # Проверяем наличие динамического поля
    my $FieldConfig = $DynamicFieldObject->DynamicFieldGet( Name => $DynamicField );
    if ( !$FieldConfig ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => "DynamicField '$DynamicField' not found!",
        );
        return 1;
    }

    # Ищем email в теле письма
    my $Body = $Param{GetParam}->{Body} || '';
    if ( $Body =~ /$Regex/m ) {
        my $FoundEmail = $1;

        my $Success = $TicketObject->TicketDynamicFieldSet(
            TicketID     => $Param{TicketID},
            DynamicField => $DynamicField,
            Value        => $FoundEmail,
            UserID       => 1,
        );

        if ($Success) {
            $LogObject->Log(
                Priority => 'notice',
                Message  => "InitiatorEmail set to $FoundEmail for Ticket $Param{TicketID}",
            );
        }
        else {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Failed to set InitiatorEmail for Ticket $Param{TicketID}",
            );
        }
    }
    else {
        $LogObject->Log(
            Priority => 'notice',
            Message  => "No matching email found in body for Ticket $Param{TicketID}",
        );
    }

    return 1;
}

1;
