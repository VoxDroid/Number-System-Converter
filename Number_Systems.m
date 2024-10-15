function number_system_converter()
    fig = uifigure('Name', 'Number System Converter', 'Position', [100 100 600 400]);
    
    input_label = uilabel(fig, 'Text', 'Input:', 'Position', [20 350 100 22]);
    input_field = uieditfield(fig, 'text', 'Position', [120 350 200 22]);
    
    from_label = uilabel(fig, 'Text', 'From:', 'Position', [20 300 100 22]);
    from_dropdown = uidropdown(fig, 'Position', [120 300 200 22], ...
        'Items', {'Binary', 'Octal', 'Decimal', 'Hexadecimal'});
    
    to_label = uilabel(fig, 'Text', 'To:', 'Position', [20 250 100 22]);
    to_dropdown = uidropdown(fig, 'Position', [120 250 200 22], ...
        'Items', {'Binary', 'Octal', 'Decimal', 'Hexadecimal'});
    
    % Create output area before referencing it in button callbacks
    output_area = uitextarea(fig, 'Position', [20 20 560 120], 'Editable', 'off');
    
    convert_button = uibutton(fig, 'Text', 'Convert', 'Position', [120 200 100 22], ...
        'ButtonPushedFcn', @(btn,event) convert_number(input_field, from_dropdown, to_dropdown, output_area));
    
    clear_button = uibutton(fig, 'Text', 'Clear', 'Position', [230 200 100 22], ...
        'ButtonPushedFcn', @(btn,event) clear_fields(input_field, output_area));
    
    output_label = uilabel(fig, 'Text', 'Output:', 'Position', [20 150 100 22]);
    
    menu = uimenu(fig, 'Text', 'Tools');
    uimenu(menu, 'Text', 'Bitwise Operations', 'MenuSelectedFcn', @(btn,event) open_bitwise_operations());
    uimenu(menu, 'Text', 'Number System Tutorial', 'MenuSelectedFcn', @(btn,event) show_tutorial());
    uimenu(menu, 'Text', 'About', 'MenuSelectedFcn', @(btn,event) show_about(fig));
end

function convert_number(input_field, from_dropdown, to_dropdown, output_area)
    % Input validation
    if isempty(input_field.Value)
        display_error(output_area, 'Input field cannot be empty.');
        return;
    end
    
    % Get input values
    input_str = input_field.Value;
    from_system = from_dropdown.Value;
    to_system = to_dropdown.Value;
    
    try
        % Convert input to decimal
        switch from_system
            case 'Binary'
                if ~all(ismember(input_str, '01'))
                    error('Invalid binary input. Use only 0 and 1.');
                end
                decimal = bin2dec(input_str);
            case 'Octal'
                if ~all(ismember(input_str, '01234567'))
                    error('Invalid octal input. Use digits 0-7.');
                end
                decimal = base2dec(input_str, 8);
            case 'Decimal'
                if ~all(ismember(input_str, '0123456789'))
                    error('Invalid decimal input. Use digits 0-9.');
                end
                decimal = str2double(input_str);
                if isnan(decimal)
                    error('Invalid decimal number.');
                end
            case 'Hexadecimal'
                if ~all(ismember(lower(input_str), '0123456789abcdef'))
                    error('Invalid hexadecimal input. Use digits 0-9 and letters A-F.');
                end
                decimal = hex2dec(input_str);
        end
        
        % Check for overflow
        if decimal > intmax('uint64') || decimal < intmin('uint64')
            error('Number is too large or small for conversion.');
        end
        
        % Convert decimal to target system
        switch to_system
            case 'Binary'
                result = dec2bin(decimal);
            case 'Octal'
                result = dec2base(decimal, 8);
            case 'Decimal'
                result = num2str(decimal);
            case 'Hexadecimal'
                result = dec2hex(decimal);
        end
        
        % Display result
        output_area.Value = sprintf('Result: %s', result);
    catch ME
        display_error(output_area, ME.message);
    end
end

function clear_fields(input_field, output_area)
    input_field.Value = '';
    output_area.Value = '';
end

function open_bitwise_operations()
    bit_fig = uifigure('Name', 'Bitwise Operations', 'Position', [200 200 400 300]);
    
    input1_label = uilabel(bit_fig, 'Text', 'Input 1:', 'Position', [20 250 100 22]);
    input1_field = uieditfield(bit_fig, 'text', 'Position', [120 250 200 22]);
    
    input2_label = uilabel(bit_fig, 'Text', 'Input 2:', 'Position', [20 200 100 22]);
    input2_field = uieditfield(bit_fig, 'text', 'Position', [120 200 200 22]);
    
    operation_label = uilabel(bit_fig, 'Text', 'Operation:', 'Position', [20 150 100 22]);
    operation_dropdown = uidropdown(bit_fig, 'Position', [120 150 200 22], ...
        'Items', {'AND', 'OR', 'XOR', 'NOT'});

    bit_output_area = uitextarea(bit_fig, 'Position', [20 20 360 30], 'Editable', 'off');
    
    calculate_button = uibutton(bit_fig, 'Text', 'Calculate', 'Position', [120 100 100 22], ...
        'ButtonPushedFcn', @(btn,event) perform_bitwise_operation(input1_field, input2_field, operation_dropdown, bit_output_area));
    
    bit_output_label = uilabel(bit_fig, 'Text', 'Output:', 'Position', [20 50 100 22]);
end

function perform_bitwise_operation(input1_field, input2_field, operation_dropdown, output_area)
    try
        % Input validation
        if isempty(input1_field.Value)
            error('Input 1 cannot be empty.');
        end
        if isempty(input2_field.Value) && ~strcmp(operation_dropdown.Value, 'NOT')
            error('Input 2 cannot be empty for this operation.');
        end
        
        a = bin2dec(input1_field.Value);
        if ~strcmp(operation_dropdown.Value, 'NOT')
            b = bin2dec(input2_field.Value);
        end
        op = operation_dropdown.Value;
        
        switch op
            case 'AND'
                result = bitand(a, b);
            case 'OR'
                result = bitor(a, b);
            case 'XOR'
                result = bitxor(a, b);
            case 'NOT'
                result = bitcmp(a, 'uint64');
        end
        
        output_area.Value = sprintf('Result: %s', dec2bin(result));
    catch ME
        display_error(output_area, ME.message);
    end
end

function show_tutorial()
    tutorial_fig = uifigure('Name', 'Number System Tutorial', 'Position', [300 300 500 400]);
    
    tutorial_text = uitextarea(tutorial_fig, 'Position', [20 20 460 360], 'Editable', 'off');
    tutorial_text.Value = sprintf(['Number System Tutorial\n\n', ...
        'Binary (Base 2):\n', ...
        '- Uses only 0 and 1\n', ...
        '- Each digit represents a power of 2\n', ...
        '- Example: 1010 = 1*2^3 + 0*2^2 + 1*2^1 + 0*2^0 = 8 + 0 + 2 + 0 = 10 (decimal)\n\n', ...
        'Octal (Base 8):\n', ...
        '- Uses digits 0-7\n', ...
        '- Each digit represents a power of 8\n', ...
        '- Example: 12 = 1*8^1 + 2*8^0 = 8 + 2 = 10 (decimal)\n\n', ...
        'Decimal (Base 10):\n', ...
        '- Uses digits 0-9\n', ...
        '- Our standard number system\n\n', ...
        'Hexadecimal (Base 16):\n', ...
        '- Uses digits 0-9 and letters A-F\n', ...
        '- Each digit represents a power of 16\n', ...
        '- Example: A = 10, B = 11, ..., F = 15\n', ...
        '- Example: 2A = 2*16^1 + 10*16^0 = 32 + 10 = 42 (decimal)']);
end

function show_about(fig)
    message = sprintf('Number System Converter v1.0\n\nCreated by Mhar Andrei Macapallag\nDate: 2024-10-06\n\nThis program provides comprehensive number system conversion and bitwise operation capabilities with a user-friendly interface.');
    uialert(fig, message, 'About', 'Icon', 'info');
end

function display_error(output_area, message)
    output_area.Value = sprintf('Error: %s', message);
end

number_system_converter();