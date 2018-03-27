function data = PTSD_FetchRatData(  )

% rat_list = {'RENN-A3C2'};
% path = 'Z:\TBI\Analysis Code\PTSD\';
% group = [0];

% rat_list = {'RENN-A10C3'};
% path = 'Z:\TBI\Analysis Code\PTSD\';
% group = [0];

% rat_list = {'RENN-A3C2', 'RENN-A9C3', 'RENN-A9C4', 'RENN-A10C2', 'RENN-A10C3'};
% path = 'Z:\TBI\Analysis Code\PTSD\';
% group = [0 0 0 0 0];

% rat_list = {'RENN-A3C2', 'RENN-A9C3', 'RENN-A9C4', 'RENN-A10C2', 'RENN-A10C3'};
% path = 'Z:\TBI\Analysis Code\PTSD\SmallSetMultipleRats\';
% group = [0 0 0 0 0];

%% C2 rats
% rat_list = {'RENN-A1C2', 'RENN-A2C2', 'RENN-A3C2', 'RENN-A4C2', 'RENN-A5C2', 'RENN-A6C2', ...
%     'RENN-A7C2', 'RENN-A8C2', 'RENN-A9C2', 'RENN-A10C2'};
% path = 'C:\Users\labuser\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C2\';
% group = [0 0 0 0 0 0 0 0 0 0];

%% C3 rats
%rat_list = {'RENN-A1C3', 'RENN-A2C3', 'RENN-A3C3', 'RENN-A4C3', 'RENN-A5C3', 'RENN-A6C3', ...
%    'RENN-A7C3', 'RENN-A8C3', 'RENN-A9C3', 'RENN-A10C3'};
% path = 'C:\Users\labuser\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C3\';
% %path = 'C:\Users\dtp110020\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C3\';
% group = [0 0 0 0 0 0 0 0 0 0];

%% C4 rats

%  rat_list = {'RENN-A1C4', 'RENN-A2C4', 'RENN-A3C4', 'RENN-A4C4', 'RENN-A5C4', 'RENN-A6C4', ...
%      'RENN-A7C4', 'RENN-A8C4', 'RENN-A9C4', 'RENN-A10C4'};
% %path = 'Z:\TBI\Analysis Code\PTSD\C4\';
% %path = 'C:\Users\labuser\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C4\';
% path = 'C:\Users\dtp110020\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C4\';
% group = [1 1 4 4 2 2 2 3 3 3];
% group_names = {'Group A', 'Group B', 'Group C'};

%% C5 rats

% rat_list = {'RENN-A1C5', 'RENN-A2C5', 'RENN-A3C5', 'RENN-A4C5', 'RENN-A5C5', 'RENN-A6C5', ...
%      'RENN-A7C5', 'RENN-A8C5', 'RENN-A9C5', 'RENN-A10C5', ...
%      'RENN-A11C5', 'RENN-A12C5', 'RENN-A13C5', 'RENN-A14C5', 'RENN-A15C5', 'RENN-A16C5'};
% path = 'C:\Users\dtp110020\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C5\';
% group = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% group_names = {'Group 1'};
% 
% data = PTSD_Dataset(rat_list, path, group, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 1, 'GroupNames', group_names);



%% C5 groups

% rat_list = {'RENN-A1C5', 'RENN-A3C5', 'RENN-A7C5', 'RENN-A9C5', 'RENN-A13C5', 'RENN-A15C5', ...
%                 'RENN-A2C5', 'RENN-A4C5', 'RENN-A8C5', 'RENN-A10C5', 'RENN-A14C5', 'RENN-A16C5', ...
%                 'RENN-A5C5', 'RENN-A11C5', ...
%                 'RENN-A6C5', 'RENN-A12C5' };
% path = 'C:\Users\dtp110020\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C5\';
% group = [1 1 1 1 1 1 ...
%     2 2 2 2 2 2 ...
%     3 3 ...
%     4 4 ];
% group_names = {'SPS + Fear', 'Control + Fear', 'SPS + No Fear', 'Control + No Fear'};
% 
% data = PTSD_Dataset(rat_list, path, group, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 1, 'GroupNames', group_names);

%% C6 rats

% rat_list = {'RENN-A1C6', 'RENN-A2C6', 'RENN-A3C6', 'RENN-A4C6', 'RENN-A5C6', 'RENN-A6C6', ...
%                 'RENN-A7C6', 'RENN-A8C6', 'RENN-A9C6', 'RENN-A10C6', 'RENN-A11C6', 'RENN-A12C6', ...
%                 'RENN-A13C6', 'RENN-A14C6', ...
%                 'RENN-A15C6', 'RENN-A16C6' };
% path = 'C:\Users\dtp110020\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C6\';
% 
% groupC6 = [1 1 1 1 2 1 1 1 1 2 4 3 3 3 3 4];
% group_names = {'SPS+AFC', 'SPS-NoAFC', 'NoSPS-AFC', 'NoSPS-NoAFC'};
% 
% data = PTSD_Dataset(rat_list, path, groupC6, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 1, 'GroupNames', group_names);

%% C8 rats

% rat_list = {'RENN-A1C8', 'RENN-A2C8', 'RENN-A3C8', 'RENN-A4C8', 'RENN-A5C8', 'RENN-A6C8', ...
%                 'RENN-A7C8', 'RENN-A8C8', 'RENN-A9C8', 'RENN-A10C8', 'RENN-A11C8', 'RENN-A12C8', ...
%                 'RENN-A13C8', 'RENN-A14C8', ...
%                 'RENN-A15C8', 'RENN-A16C8' };
% path = 'C:\Users\dtp110020\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C8\';
% 
% groupC8 = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% group_names = {'No group'};
% 
% data = PTSD_Dataset(rat_list, path, groupC8, 'LoadBinaries', 0, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 0, 'GroupNames', group_names);


% rat_list = {'RENN-A1C5', 'RENN-A3C5', 'RENN-A7C5', 'RENN-A9C5', 'RENN-A13C5', 'RENN-A15C5'};
% path = 'C:\Users\dtp110020\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C5\';
% group = [1 1 1 1 1 1];
% group_names = {'SPS + Fear'};
% 
% data = PTSD_Dataset(rat_list, path, group, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 1, 'GroupNames', group_names);
% 
% rat_list = {'RENN-A2C5', 'RENN-A4C5', 'RENN-A8C5', 'RENN-A10C5', 'RENN-A14C5', 'RENN-A16C5'};
% path = 'C:\Users\dtp110020\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C5\';
% group = [1 1 1 1 1 1];
% group_names = {'Control + Fear'};
% 
% 
% data2 = PTSD_Dataset(rat_list, path, group, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 1, 'GroupNames', group_names);
% 
% 
% rat_list = {'RENN-A5C5', 'RENN-A11C5'};
% path = 'C:\Users\dtp110020\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C5\';
% group = [1 1 1 1 1 1];
% group_names = {'SPS + No Fear'};
% 
% data3 = PTSD_Dataset(rat_list, path, group, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 1, 'GroupNames', group_names);
% 
% 
% rat_list = {'RENN-A6C5', 'RENN-A12C5'};
% path = 'C:\Users\dtp110020\Google Drive\TBI Project\PTSD m maze\analysis\David Code\C5\';
% group = [1 1 1 1 1 1];
% group_names = {'Control + No Fear'};
% 
% data4 = PTSD_Dataset(rat_list, path, group, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 1, 'GroupNames', group_names);
% 

%% Rimenez's rats

% rat_list = {'A1R3', 'A2R3', 'A3R3', 'A4R3', 'A5R3', ...
%      'A6R3', 'A7R3', 'A8R3', 'A9R3', 'A10R3', ....
%      'A11R3', 'A12R3', 'A13R3', 'A14R3', 'A15R3', ...
%      'A16R3', 'A17R3', 'A18R3', 'A19R3', 'A20R3',};
% path = 'Z:\TBI\Analysis Code\PTSD\R3 Clean data\';
% 
% groups_rimenez = [3 3 3 3 3 4 4 4 4 4 1 1 1 1 1 2 2 2 2 2];
% group_names = {'HC-noAFC', 'HC-AFC', 'SPS-noAFC', 'SPS-AFC'};
% 
% data = PTSD_Dataset(rat_list, path, groups_rimenez, 'LoadBinaries', 0, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 1, 'GroupNames', group_names);

%% Rimenez's R4 rats

% rat_list = {'A1R4','A2R4','A3R4','A4R4','A5R4','A6R4','A7R4','A8R4','A9R4','A10R4',...
%     'A11R4','A12R4','A13R4','A14R4'};
% 
% path = 'Z:\TBI\Analysis Code\PTSD\R4\';
% 
% groupR4 = [1 1 2 1 1 1 1 2 2 2 2 1 2 2];
% group_names = {'AFC+/SPS-', 'AFC+/SPS+'};
% 
% dataR4 = PTSD_Dataset(rat_list, path, groupR4, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 0, 'GroupNames', group_names);

%%LATEST VERSION ALL GROUPS
rat_list = {'A3R2A','A4R2A','A7R2A','A8R2A','A11R3','A12R3','A13R3','A14R3',...
            'A2R2B','A8R2B','A10R2B','A1R3','A3R3','A5R3',...
            'A1R2A','A2R2A','A5R2A','A10R2A',...
            'A16R3','A17R3','A18R3','A19R3','A20R3',...
            'A6R3','A8R3','A9R3',...
            'A1R4','A2R4','A4R4','A5R4','A6R4','A7R4','A12R4',...
            'A3R4','A8R4','A9R4','A10R4','A11R4','A13R4','A14R4',...
            'A15R4','A16R4','A17R4','A18R4','A20R4',};

%path = 'C:\Users\dtp110020\Desktop\All data analysis-20160829T173620Z\All data analysis\';
path = 'Z:\TBI\Analysis Code\PTSD\All data analysis\';

groupALL = [1 1 1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 4 4 4 4 4 5 5 5 6 6 6 6 6 6 6 7 7 7 7 7 7 7 8 8 8 8 8];

group_names = {'SPS-/AFC-',... 
    'SPS+/AFC-',...
    'SPS-/AFC+ 0.8mA 9kHz 16CS+US',...
    'SPS-/AFC+ 0.8mA 9kHz 64CS+US/50%',... 
    'SPS+/AFC+ 0.8mA 9kHz 64CS+US/50%'...
    'SPS-/AFC+ 2.0mA warzone 8CS+US',...
    'AFC+/SPS+ 2.0mA warzone 8CS+US',...
    'SPS+/AFC+ 2.0mA warzone 8CS+US',};

dataALL = PTSD_Dataset(rat_list, path, groupALL, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
    'DisplayDateVerification', 1, 'GroupNames', group_names);

%% R5 Rats that have date problems

rat_list = {'A8R5', 'A11R5', 'A14R5','A16R5',...
            'A2R5', 'A4R5', 'A10R5','A17R5','A18R5','A19R5',...
            'A1R5','A6R5','A7R5','A9R5','A15R5','A20R5'}

path = 'Z:\TBI\Analysis Code\PTSD\R5';

groupALL = [1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3];

group_names = {'SPS-/AFC-', 'SPS+/AFC+ warzone 32X', 'SPS+/AFC+ warzone 64X'};

dataALL = PTSD_Dataset(rat_list, path, groupALL, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
    'DisplayDateVerification', 1, 'GroupNames', group_names);


%% R5

rat_list = {'A8R5', 'A11R5', 'A14R5','A16R5',...
            'A2R5', 'A4R5', 'A10R5','A17R5','A18R5','A19R5',...
            'A1R5','A6R5','A7R5','A9R5','A15R5','A20R5'}

%path = 'C:\Users\rxr166230\Desktop\Data ANALYSIS\R5';
path = 'Z:\TBI\Analysis Code\PTSD\R5';

groupALL = [1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3];

group_names = {'SPS-/AFC-', 'SPS+/AFC+ warzone 32X', 'SPS+/AFC+ warzone 64X'};

dataALL = PTSD_Dataset(rat_list, path, groupALL, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
    'DisplayDateVerification', 1, 'GroupNames', group_names);


%% R5 and R6

rat_list = {'A8R5','A11R5', 'A14R5','A16R5','A3R6','A5R6','A16R6','A21R6',...
            'A11R6','A14R6','A19R6','A20R6',...
            'A7R6','A12R6','A18R6','A22R6',...
            'A6R6','A13R6','AR17R6',...
            'A2R5','A4R5', 'A10R5','A18R5','A19R5','A2R6','A9R6','A12R6',...
            'A1R5','A6R5','A7R5','A9R5','A15R5','A20R5','A1R6','A4R6','A8R6'}

path = 'Z:\TBI\Analysis Code\PTSD\R5 and R6';

groupALL = [1 1 1 1 1 1 1 1 ...
            2 2 2 2 ...
            3 3 3 3 ...
            4 4 4 ...
            5 5 5 5 5 5 5 5 ...
            6 6 6 6 6 6 6 6 6];

group_names = {'CONTROL', 'SPS+', 'AFC warzone', 'MMAZE warzone', 'SPS+/AFC warzone', 'SPS+/MMAZE warzone'};

dataALL = PTSD_Dataset(rat_list, path, groupALL, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
    'DisplayDateVerification', 1, 'GroupNames', group_names);


%% Files not loading

rat_list = {'A10R6', 'A15R6', 'A17R6'};
path = 'Z:\TBI\Analysis Code\PTSD\Files not loading';
group = [1 1 1];
group_names = {'not working'};
data =  PTSD_Dataset(rat_list, path, group, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
    'DisplayDateVerification', 1, 'GroupNames', group_names);

%% Rimenez's rats - pre only

% rat_list = {'A1R3', 'A2R3', 'A3R3', 'A4R3', 'A5R3', ...
%      'A6R3', 'A7R3', 'A8R3', 'A9R3', 'A10R3', ....
%      'A11R3', 'A12R3', 'A13R3', 'A14R3', 'A15R3', ...
%      'A16R3', 'A17R3', 'A18R3', 'A19R3', 'A20R3',};
% path = 'Z:\TBI\Analysis Code\PTSD\R3 Pre\';
% 
% groups_rimenez = [3 3 3 3 3 4 4 4 4 4 1 1 1 1 1 2 2 2 2 2];
% group_names = {'HC-noAFC', 'HC-AFC', 'SPS-noAFC', 'SPS-AFC'};
% 
% data = PTSD_Dataset(rat_list, path, groups_rimenez, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 1, 'GroupNames', group_names);



%% Test for Holle
% 
% rat_list = {'A1C3', 'A2C3', 'A9C3' };
% path = 'C:\Users\dtp110020\Desktop\New_Booth_Data_(C3_animals)-2016-02-24\New Booth Data (C3 animals)\';
% group = [1 1 1];
% group_names = {'No group'};
% 
% data = PTSD_Dataset(rat_list, path, group, 'LoadBinaries', 1, 'ForceSaveBinaries', 1, ...
%     'DisplayDateVerification', 0, 'GroupNames', group_names);

end

