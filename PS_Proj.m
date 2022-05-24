%% This Project was Prepared By:
% Ahmed Aly Gamal El-Din El-Ghannam  19015292
% Ahmed Sherif Ahmed Mahmoud Ghanim  19015255
% Kerollos Saad Thomas Shokrallah    19016188
% Yahia Walid Mohamed El-Dakhakhny   19016891
% Ahmed Yosri Ahmed Arafa            17010296

%% Prologue: Setup
clear;
clc;
fprintf('Welcome to the Transmission Line Wizard >> \n\n');

%% Task_1: Transmission Line Parameters

%% A) Reading Values from the User
% Storing Resistivity
ConResistivity = input("Please Enter a Value for the Conductor's Resistivity in ohm.m:  ");

% Storing Length
ConLength = input("Please Enter a Value for the Conductor's Length in km:  ");

% Storing Diameter
ConDiameter = input("Please Enter a Value for the Conductor's Diameter in m:  ");

% Calculating Radius
ConRadius = (ConDiameter / 2);

% Calculating Conductor Length in m
ConLength_m = (ConLength) * 1e3;

%% B) Inductance and Capacitance Parameters
% Spacing Between Conductors
spacing = read_spacing();

while (1)
    
    % Symmetric
    if (spacing == 1)
       % Calculating GMD
       GMD = input("Please Enter a Value for the Distance Between Conductors in m:  "); 
       break;
    
    % Asymmetric
    elseif (spacing == 2)
        D_12 = input("Please Enter a Value for the Distance Between Conductors One and Two in m:  ");
        D_23 = input("Please Enter a Value for the Distance Between Conductors Two and Three in m:  ");
        D_13 = input("Please Enter a Value for the Distance Between Conductors One and Three in m:  ");
        % Calculating GMD
        GMD = nthroot((D_12 * D_23 * D_13), 3);
        break;
    % Idiotproofing Spacing
    else
        fprintf('Invalid Input! \nChoose Either 1 or 2 ONLY.\n');
        spacing = read_spacing();
    end
    
end

%% Calculating Resistance

%Calculating Area
area = (pi / 4) * (ConDiameter * ConDiameter);

% DC Resistance
R_DC = (ConResistivity * ConLength_m ) / area;

% AC Resistance
R_AC = 1.1 * R_DC;

%% Calculating Inductance

% Magnetic Permeability
meu = (4 * pi) * 1e-7;


% Geometric Mean Radius
GMR = ConRadius * exp(-0.25);

% Inductance Per Phase
L_per_m = (meu / (2 * pi)) * log(GMD / GMR);

% Inductance
L_phase = L_per_m * ConLength_m;

%% Calculating Capacitance

% Electric Permitivity
epsilon = 8.85e-12;

% Capacitance Per Phase
C_per_m = (2 * pi * epsilon) / log(GMD / ConRadius);

% Capacitance
C_phase = C_per_m * ConLength_m;

%%%%%%%% End of Transmission Line Parameters %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Task 2: ABCD Parameters

% Defining sqrt(-1) as j
j = 1i;

% Calculating OMEGA (Assuming f = 50Hz)
f = 50;
omega = 2 * pi * f;

% Calculating Inductive Reactance
XL = (j * omega * L_phase);

% Calculating Capacitive Reactance
XC = 1 / (j * omega * C_phase);

% Calculating Impedence
Z = R_AC + XL;

% Calculating Admittance
Y = (j * omega  * C_phase);

% Determining The Transmission Line Model Based on its Length
if (ConLength <= 80)
    % Identifying Transmission Line Model Used as Short
    state = 0;
    fprintf('\nBased on the Line Length Entered\n The Transmission line is Short.\n');
    
    % Short Line Parameters are Used
    A = 1;
    B = Z;
    C = 0;
    D = 1; 
    
elseif (ConLength <= 250)  
    
    % Identifying Transmission Line Model Used as Medium
    state = 81;
    fprintf('\nBased on the Line Length Entered\n The Transmission line is Medium.\n');
        
    % Medium Line Parameters are Used Based on the Circuit Model
    model = line_model();
        
    % Idiotproofing Model
    while (1)
    
      if (model == 1)
          % Medium Line Parameters for PI Model
          A = 1 + (Y * Z / 2);
          B = Z;
          C = Y * (1 + (Y * Z / 4));
          D = 1 + ((Y * Z) / 2);
          %Printing the Calculated Variables 
          variables_disp(R_AC, C_phase, L_phase, XL, XC, Y, Z, A, B, C, D);
          break;
                
      elseif (model == 2)
          % Medium Line Parameters for T Model
          A = 1 + (Y * Z / 2);
          B = Z * (1 + (Y * Z / 4));
          C = Y;
          D = 1 + (Y * Z / 2);
          %Printing the Calculated Variables 
          variables_disp(R_AC, C_phase, L_phase, XL, XC, Y, Z, A, B, C, D);
          break;
      else
          disp("Invalid Input! Try Again");
          model = line_model();
      end
            
    end    

else
    state = 251;
    fprintf('\nBased on the Line Length Entered\n The Transmission line is Long.\n');
    fprintf('This Program is not Designed to Calculate Long Transmission Line Parameters.\nTerminated ..');
    
end

%%%%%%%%%%%%%%%%% ABCD Parameters %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Task 3: Transmission Line Performance

if (state ~= 251)
    % Choosing Which case to Output Based on the User's Choice
    decider = case_decider();
    
    % Prologue : Prompting the User to Enter the Receiving-end Voltage
    Vr = input('Please Enter a Value for The Receiving-End Phase Voltage in v:  ');
    while (1)
        if (decider == 1)
            % Case I
            task3_case1(A, B, C, D, Vr, j);
            break;
                
        elseif (decider == 2)
            % Case II
            task3_case2(A, B, C, D, Vr, j);
            break;
        else
            fprintf('Invalid Input! \nChoose either 1 or 2 ONLY.\n');
            decider = case_decider();
        end
    end
    goodbye_message();
end

%%%%%%%%%%% Transmission Line Performance %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Functions Used. Put at The End of Program

%% Function that Reads Spacing Between Conductors
function spac = read_spacing()
    fprintf('\nPlease Choose the Type of the Conductor Spacing >>\n  1)Symmetric Spacings \n  2)Asymmetric Spacing \n\n');
    spac = input('Your Choice: '); 
    fprintf('\n');
end

%% Function that Reads the User's Choice between PI and T Models
function mod = line_model()
    fprintf('Please Select the Model Type >>\n  1)PI Model \n  2)T Model \n\n');
    mod = input('Your Choice: ');
    fprintf('\n');
end

%% Function that Prints the Calculated Transmission Line Data
function variables_disp(R_AC, C_phase, L_phase, XL, XC, Y, Z, A, B, C, D)
    fprintf('Transmission Line Parameters: \n');
    % Printing AC Resistance
    fprintf('\tAC Phase Resistance = %0.3f ohm\n', R_AC);
    % Printing Phase Capacitance
    fprintf('\tPhase Capacitance = %0.3f F\n', C_phase);
    % Printing Phase Inductance
    fprintf('\tPhase Inductance = %0.3f H\n', L_phase);
    % Printing Reactances
    fprintf('\tPhase Inductive Reactance = %0.3f + j%0.3f ohm\n', real(XL), imag(XL));
    fprintf('\tPhase Capacitive Reactance = %0.3f + j%0.3f ohm\n', real(XC), imag(XC));
    % Printing Admittance
    fprintf('\tPhase Admittance = %0.3f + j%0.3f seimens\n', real(Y), imag(Y));
    % Printing Impedence
    fprintf('\tPhase Impedence = %0.3f + j%0.3f ohm\n', real(Z), imag(Z));
    % Printing ABCD
    fprintf('ABCD Parameters: \n');
    fprintf('\tA = %0.3f + j%0.3f\n', real(A), imag(A));
    fprintf('\tB = %0.3f + j%0.3f\n', real(B), imag(B));
    fprintf('\tC = %0.3f + j%0.3f\n', real(C), imag(C));
    fprintf('\tD = %0.3f + j%0.3f\n\n\n', real(D), imag(D)); 
end

%% Function that Reads the User's Choice between Case I and Case II
function choice = case_decider()
    fprintf('\n');
    fprintf('Please Select the Desired Case Output  >>\n');
    fprintf('1)Case I: Efficiency & Voltage Regulation vs Active Power\n');
    fprintf('2)Case II: Efficiency & Voltage Regulation vs Lagging and Leading PF \n\n');
    choice = input('Your Choice: ');
    fprintf('\n\n');
end

%% Function Used to Plot the Graphs Required in Task 3 Case I
function task3_case1(A, B, C, D, Vr, j)
    %% Initialize Power Factor (Constant, Given)
    pf = 0.8;
    
    %% Active Power Varying Between 0 and 100kW at Receiving End
    Pr = 0:0.5:100;
    % Measuring Active Power in W and Dividing by 3 to get Power per Phase
    Pr = Pr.*1000/3;
   
    %% Calculating the Value of Receiving-end Current
    Ir = (Pr ./ ( Vr * pf)) * exp(-j * acos(pf));
    
    %% Calculating Sending-end Values
    Vs = (A * Vr) + (B .* Ir);
    Is = (C * Vr) + (D .* Ir);
    Ss = Vs .* conj(Is);
    Ps = real(Ss);
    
    %% Calculating Efficiency
    eff = Pr ./ Ps;
    
    %% Calculating Receiving-end Voltage @ no load
    Vr_nl = Vs ./ A;
    
    %% Calculating Voltage Regulation
    V_R = (abs(Vr_nl) - Vr) ./ Vr;
    
    %% Measuring Active Power in kW and Reverting it to its Original Three-phase State 
    Pr = Pr.*3/1000;
    
    %% Graphs
    % Plotting Efficiency in % vs Active Power in kW
    figure
    subplot(121)
    plot(Pr, eff.*100); 
    grid on
    title('Efficiency (%) vs Active Power (kW)')
    
    % Plotting Voltage Regulation (%) vs Active Power
    subplot(122)
    plot(Pr, V_R.*100); 
    grid on
    title('Plotting Voltage Regulation (%) vs Active Power')
    
end

%% Function Used to Plot the Graphs Required in Task 3 Case II
function task3_case2(A, B, C, D, Vr, j)
    %% Defining Active Power @ Receiving End
    Pr = 100e3/3;
    
    %% Defining Power Factor Ranging between 0.3 and 1
    pf = 0.3:0.01:1;

    %% Calculating the Value of Receiving-end Current
    Ir_lag = (Pr ./ (Vr .* pf)) .* exp(j .* acos(pf));
    Ir_lead = (Pr ./ (Vr .* pf)) .* exp(-j .* acos(pf));
    
    %% Calculations @ Lagging Power Factor
    % Calculating Sending-End Values
    Vs_lag = (A * Vr) + (B .* Ir_lag);
    Is_lag = (C * Vr) + (D .* Ir_lag);
    Ss_lag = Vs_lag .* conj(Is_lag);
    Ps_lag = real(Ss_lag);
    
    % Calculating Efficiency
    eff_lag = Pr./Ps_lag; 
    
    % Calculating Receiving-end Voltage @ no load
    Vrnl_lag = Vs_lag./A; 
    
    % Calculating Voltage Regulation
    V_R_lag = (abs(Vrnl_lag) - Vr)./Vr;
    
    %% Calculations @ Leading Power Factor
    % Calculating Sending-End Values
    Vs_lead = A*Vr + B.*Ir_lead;
    Is_lead = C*Vr + D.*Ir_lead;
    Ss_lead = Vs_lead.*conj(Is_lead);
    Ps_lead = real(Ss_lead);
    
    % Calculating Efficiency
    eff_lead = Pr./Ps_lead;
    
    % Calculating Receiving-end Voltage @ no load
    Vrnl_lead = Vs_lead./A; 
    
    % Calculating Voltage Regulation
    V_R_lead = (abs(Vrnl_lead) - Vr)./Vr;
    
    %% Graphs @ Lagging Power Factor
    % Plotting Efficiency vs Power Factor 
    figure
    subplot(221)
    plot(pf, eff_lag*100)
    grid on
    title("Efficiency (%) vs Lagging PF")

    % Plotting Voltage Regulation vs Power Factor
    subplot(222)
    plot(pf, V_R_lag*100)
    grid on
    title("Voltage Regulation (%) vs Lagging PF")
    
    %% Graphs @ Leading Power Factor
    % Plotting Efficiency vs Power Factor
    subplot(223)
    plot(pf, eff_lead*100)
    grid on
    title("Efficiency (%) vs Leading PF")
    % Plotting Voltage Regulation vs Power Factor
    subplot(224)
    plot(pf, V_R_lead*100)
    grid on
    title("Voltage Regulation vs Leading PF")
    
end

%% Function that Displays the End Message
function goodbye_message()
    fprintf('\n\n');
    fprintf('Thank You for Using our Program\n');
    fprintf('Feel Free to Leave a Tip for the Developers\n');
    fprintf('A D I O S\n');
end

    








