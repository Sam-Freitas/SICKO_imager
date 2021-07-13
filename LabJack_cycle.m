function LabJack_cycle(channel,voltage)
% Created by Samuel Freitas 7/23/2020
% Turns on or off (0v or 5v) on DAC0/1 for a LabJack U3

ljasm = NET.addAssembly('LJUDDotNet');
ljudObj = LabJack.LabJackUD.LJUD;

try
    % Read and display the UD version.
%     disp(['UD Driver Version = ' num2str(ljudObj.GetDriverVersion())])
    
    % Open the first found LabJack U3.
    [ljerror, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);
    
    % Start by using the pin_configuration_reset IOType so that all pin
    % assignments are in the factory default condition.
    ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);
    
    % Set DAC0 to 5.0 volts.
    binary = 0;
    ljudObj.eDAC(ljhandle, channel, voltage, binary, 0, 0);
    
    disp(['DAC' num2str(channel) ' set to ' num2str(voltage) 'V']);
    
    
catch
    disp('LabJack setup error');
end

end
