function generatedFiles = convert_csv_to_LOG(inputCsvFile,outputDir,overwriteExisting)
% CONVERT_CSV_TO_LOG Split a combined NoSeMaze detector log by day.
%
% Expected CSV columns:
%   Date_time, UnitNumber, TransponderCode
%
% Each output MAT file contains table Data:
%   Day, Time_hour, Time_sec, Detector, Animal

arguments
    inputCsvFile (1,:) char
    outputDir (1,:) char
    overwriteExisting (1,1) logical = false
end

if ~isfile(inputCsvFile)
    error('Raw tube CSV not found:\n%s',inputCsvFile);
end
if ~isfolder(outputDir)
    mkdir(outputDir);
end

A = readtable(inputCsvFile,'VariableNamingRule','preserve');

required = {'Date_time','UnitNumber','TransponderCode'};
missing = setdiff(required,A.Properties.VariableNames);
if ~isempty(missing)
    error('CSV missing required column(s): %s',strjoin(missing,', '));
end

rawDT = A.Date_time;
if isdatetime(rawDT)
    dt = rawDT;
else
    txt = string(rawDT);
    try
        dt = datetime(txt,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
    catch
        dt = datetime(txt);
    end
end

Day = cellstr(string(dt,'yyyy-MM-dd'));
Time_hour = hours(timeofday(dt));
Time_sec = seconds(timeofday(dt));
Detector = A.UnitNumber;
Animal = cellstr(string(A.TransponderCode));

Data_full = table( ...
    Day,Time_hour,Time_sec,Detector,Animal, ...
    'VariableNames',{'Day','Time_hour','Time_sec','Detector','Animal'});

uniqueDays = unique(Data_full.Day,'stable');
generatedFiles = cell(numel(uniqueDays),1);

for dayIndex = 1:numel(uniqueDays)

    currentDay = uniqueDays{dayIndex};
    Data = Data_full(strcmp(Data_full.Day,currentDay),:); %#ok<NASGU>

    outputFile = fullfile(outputDir,['LOG_' currentDay '.mat']);
    generatedFiles{dayIndex} = outputFile;

    if isfile(outputFile) && ~overwriteExisting
        fprintf('Keeping existing: %s\n',outputFile);
        continue;
    end

    save(outputFile,'Data');
    fprintf('Saved %d detections: %s\n',height(Data),outputFile);
end
end
