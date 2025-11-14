#!/usr/bin/env python3
"""
Droid TOON Integration Module
Integrates Token-Oriented Object Notation into Droid's DNA for optimal token efficiency

This module provides TOON encoding/decoding capabilities specifically designed
for Droid's tool outputs, structured responses, and data communication.
"""

import json
import re
from typing import Any, Dict, List, Union, Optional
from dataclasses import dataclass
from enum import Enum


class DataType(Enum):
    """Data types supported by TOON"""
    OBJECT = "object"
    ARRAY = "array"
    STRING = "string"
    NUMBER = "number"
    BOOLEAN = "boolean"
    NULL = "null"


@dataclass
class TOONConfig:
    """Configuration for TOON encoding"""
    indent_size: int = 2
    use_commas: bool = True
    compact_strings: bool = False
    max_nesting_depth: int = 3
    prefer_arrays: bool = True


class TOONEncoder:
    """Main TOON encoder for Droid integration"""
    
    def __init__(self, config: Optional[TOONConfig] = None):
        self.config = config or TOONConfig()
        
    def encode(self, data: Any) -> str:
        """
        Encode data as TOON format
        
        Args:
            data: Any JSON-serializable data
            
        Returns:
            TOON-formatted string
        """
        if data is None:
            return "null"
            
        data_type = self._get_data_type(data)
        
        if data_type == DataType.OBJECT:
            return self._encode_object(data)
        elif data_type == DataType.ARRAY:
            return self._encode_array(data)
        elif data_type == DataType.STRING:
            return self._encode_string(data)
        elif data_type in [DataType.NUMBER, DataType.BOOLEAN]:
            return str(data)
        else:
            return "null"
    
    def _encode_object(self, obj: Dict[str, Any]) -> str:
        """Encode dictionary as TOON"""
        if not obj:
            return "{}"
            
        # Check if this is a flat, tabular structure
        if self._is_tabular(obj):
            return self._encode_tabular_object(obj)
        else:
            return self._encode_simple_object(obj)
    
    def _is_tabular(self, obj: Dict[str, Any]) -> bool:
        """Check if object is suitable for tabular TOON format"""
        # Look for array of similar objects
        values = list(obj.values())
        if len(values) == 1 and isinstance(values[0], list):
            return True
        return False
    
    def _encode_tabular_object(self, obj: Dict[str, Any]) -> str:
        """Encode tabular data (array of objects) to TOON"""
        # Find the array value
        array_key = None
        array_value = None
        
        for key, value in obj.items():
            if isinstance(value, list) and len(value) > 0:
                array_key = key
                array_value = value
                break
        
        if not array_value:
            return self._encode_simple_object(obj)
        
        # Get column names from first object
        if isinstance(array_value[0], dict):
            columns = list(array_value[0].keys())
            # Build TOON header
            header = f"{array_key}[{len(array_value)]}{{{','.join(columns)}}}:"
            
            # Build data rows
            rows = []
            for item in array_value:
                if isinstance(item, dict):
                    row_values = []
                    for col in columns:
                        val = item.get(col, "")
                        if isinstance(val, str) and ("," in val or " " in val):
                            val = f'"{val}"'
                        row_values.append(str(val))
                    rows.append("  " + ",".join(row_values))
            
            return header + "\n" + "\n".join(rows)
        
        return self._encode_simple_object(obj)
    
    def _encode_simple_object(self, obj: Dict[str, Any]) -> str:
        """Encode simple object with key-value pairs"""
        lines = []
        indent = " " * self.config.indent_size
        
        for key, value in obj.items():
            if isinstance(value, (str, int, float, bool)) or value is None:
                lines.append(f"{key}: {self._encode_simple_value(value)}")
            elif isinstance(value, dict):
                if value and self.config.max_nesting_depth > 0:
                    nested_toon = self._encode_object(value)
                    lines.append(f"{key}:\n{indent}{nested_toon}")
                else:
                    lines.append(f"{key}: {json.dumps(value)}")
            elif isinstance(value, list):
                if value and self.config.max_nesting_depth > 0:
                    nested_toon = self._encode_array(value)
                    lines.append(f"{key}:\n{indent}{nested_toon}")
                else:
                    lines.append(f"{key}: {json.dumps(value)}")
        
        return "\n".join(lines)
    
    def _encode_array(self, arr: List[Any]) -> str:
        """Encode array as TOON"""
        if not arr:
            return "[]"
        
        # Check if array contains similar structures
        if self._is_uniform_array(arr):
            return self._encode_uniform_array(arr)
        else:
            lines = []
            for i, item in enumerate(arr):
                encoded_item = self.encode(item)
                lines.append(f"{i}: {encoded_item}")
            return "\n".join(lines)
    
    def _is_uniform_array(self, arr: List[Any]) -> bool:
        """Check if array contains similar objects"""
        if len(arr) <= 1:
            return False
            
        first_type = type(arr[0])
        if first_type != dict:
            return False
            
        first_keys = set(arr[0].keys()) if isinstance(arr[0], dict) else set()
        
        for item in arr[1:]:
            if not isinstance(item, dict):
                return False
            if set(item.keys()) != first_keys:
                return False
        
        return True
    
    def _encode_uniform_array(self, arr: List[Dict[str, Any]]) -> str:
        """Encode uniform array of objects in tabular TOON"""
        if not arr:
            return "[]"
        
        columns = list(arr[0].keys())
        header = f"[{len(arr)}]{{{','.join(columns)}}}:"
        
        rows = []
        for item in arr:
            row_values = []
            for col in columns:
                val = item.get(col, "")
                if isinstance(val, str) and ("," in val or "\n" in val):
                    # Escape complex strings
                    escaped_val = val.replace('"', '""').replace('\n', '\\n')
                    row_values.append(f'"{escaped_val}"')
                elif val is None:
                    row_values.append("null")
                else:
                    row_values.append(str(val))
            rows.append("  " + ",".join(row_values))
        
        return header + "\n" + "\n".join(rows)
    
    def _encode_string(self, value: str) -> str:
        """Encode string value"""
        if self.config.compact_strings and not any(c in value for c in [",", "\n", ":", " "]):
            return value
        else:
            # Escape quotes and newlines
            escaped = value.replace('"', '""').replace('\n', '\\n')
            return f'"{escaped}"'
    
    def _encode_simple_value(self, value: Any) -> str:
        """Encode simple scalar value"""
        if value is None:
            return "null"
        elif isinstance(value, bool):
            return str(value).lower()
        elif isinstance(value, (int, float)):
            return str(value)
        elif isinstance(value, str):
            return self._encode_string(value)
        else:
            return json.dumps(value)
    
    def _get_data_type(self, data: Any) -> DataType:
        """Determine data type"""
        if isinstance(data, dict):
            return DataType.OBJECT
        elif isinstance(data, list):
            return DataType.ARRAY
        elif isinstance(data, str):
            return DataType.STRING
        elif isinstance(data, (int, float)):
            return DataType.NUMBER
        elif isinstance(data, bool):
            return DataType.BOOLEAN
        elif data is None:
            return DataType.NULL
        else:
            return DataType.OBJECT


class TOONDecoder:
    """TOON decoder for processing TOON-formatted data"""
    
    def __init__(self):
        pass
    
    def decode(self, toon_str: str) -> Any:
        """
        Decode TOON string back to Python objects
        
        Args:
            toon_str: TOON-formatted string
            
        Returns:
            Decoded Python object
        """
        lines = toon_str.strip().split('\n')
        if not lines:
            return None
            
        # Try to parse as tabular format first
        if self._is_tabular_format(lines[0]):
            return self._decode_tabular(lines)
        else:
            return self._decode_key_value(lines)
    
    def _is_tabular_format(self, first_line: str) -> bool:
        """Check if first line indicates tabular format"""
        return ("[" in first_line and "]" in first_line and 
                "{" in first_line and "}" in first_line and
                first_line.endswith(":"))
    
    def _decode_tabular(self, lines: List[str]) -> Dict[str, Any]:
        """Decode tabular TOON format"""
        if not lines:
            return {}
        
        # Parse header
        header = lines[0]
        match = re.match(r'^(.+)\[(\d+)\]\{(.+)\}:', header)
        if not match:
            return self._decode_key_value(lines)
        
        key, count, columns_str = match.groups()
        columns = [col.strip() for col in columns_str.split(',')]
        
        # Parse data rows
        data = []
        for line in lines[1:]:
            line = line.strip()
            if not line:
                continue
                
            values = self._parse_csv_line(line)
            obj = dict(zip(columns, values))
            
            # Convert data types
            for k, v in obj.items():
                obj[k] = self._convert_value(v)
            
            data.append(obj)
        
        return {key.strip(): data}
    
    def _parse_csv_line(self, line: str) -> List[str]:
        """Parse CSV-like line with quoted strings"""
        values = []
        current = ""
        in_quotes = False
        
        for char in line:
            if in_quotes:
                if char == '"':
                    in_quotes = False
                else:
                    current += char
            else:
                if char == '"':
                    in_quotes = True
                elif char == ',':
                    values.append(current)
                    current = ""
                else:
                    current += char
        
        values.append(current)
        return values
    
    def _convert_value(self, value: str) -> Any:
        """Convert string value to appropriate type"""
        if value.lower() == "null":
            return None
        elif value.lower() == "true":
            return True
        elif value.lower() == "false":
            return False
        elif value.isdigit():
            return int(value)
        elif value.replace('.', '').replace('-', '').isdigit():
            return float(value)
        else:
            return value
    
    def _decode_key_value(self, lines: List[str]) -> Dict[str, Any]:
        """Decode key-value format"""
        result = {}
        current_key = None
        current_value = []
        in_multiline = False
        
        for line in lines:
            line = line.rstrip()
            if not line:
                if in_multiline:
                    current_value.append("")
                continue
            
            # Check if it's a new key-value pair
            if ':' in line and not line.startswith('  ') and not line.startswith('\t'):
                # Save previous key-value if exists
                if current_key is not None:
                    result[current_key] = self._parse_value(current_value)
                
                # Start new key-value
                parts = line.split(':', 1)
                current_key = parts[0].strip()
                if len(parts) > 1:
                    value_part = parts[1].strip()
                    if value_part:
                        current_value = [value_part]
                        in_multiline = False
                    else:
                        current_value = []
                        in_multiline = True
                else:
                    current_value = []
                    in_multiline = True
            else:
                # Continuation of current value
                current_value.append(line.lstrip())
        
        # Save last key-value
        if current_key is not None:
            result[current_key] = self._parse_value(current_value)
        
        return result
    
    def _parse_value(self, value_list: List[str]) -> Any:
        """Parse value from list of strings"""
        if not value_list:
            return ""
        elif len(value_list) == 1:
            value = value_list[0]
            if value.startswith('"') and value.endswith('"'):
                return value[1:-1].replace('""', '"').replace('\\n', '\n')
            elif value.lower() == "null":
                return None
            elif value.lower() == "true":
                return True
            elif value.lower() == "false":
                return False
            elif value.isdigit():
                return int(value)
            elif value.replace('.', '').replace('-', '').isdigit():
                return float(value)
            else:
                return value
        else:
            return " ".join(value_list)


class Droid TOONIntegration:
    """
    Main Integration Class for Droid TOON functionality
    
    This class provides the interface between Droid operations and TOON encoding,
    automatically deciding when to use TOON vs traditional JSON based on data characteristics.
    """
    
    def __init__(self, config: Optional[TOONConfig] = None):
        self.encoder = TOONEncoder(config)
        self.decoder = TOONDecoder()
        self.json_encoder = json.JSONEncoder(indent=2)
    
    def format_for_droid(self, data: Any, context: str = "tool_result") -> str:
        """
        Format data for Droid consumption, choosing optimal format
        
        Args:
            data: Data to format
            context: Context (tool_result, prompt, config, etc.)
            
        Returns:
            Formatted string (TOON or JSON)
        """
        # Decide if TOON is appropriate
        if self._should_use_toon(data, context):
            return self._format_toon(data)
        else:
            return self._format_json(data)
    
    def _should_use_toon(self, data: Any, context: str) -> bool:
        """Decide if TOON should be used based on data characteristics"""
        # Always use TOON for tool results with array data
        if context == "tool_result":
            return self._is_toon_suitable(data)
        
        # Use TOON for large tabular data
        if isinstance(data, dict):
            for value in data.values():
                if isinstance(value, list) and len(value) > 2:
                    return self._is_toon_suitable(value)
        
        # Use JSON for deeply nested or complex structures
        return False and self._is_toon_suitable(data)
    
    def _is_toon_suitable(self, data: Any) -> bool:
        """Check if data structure is suitable for TOON"""
        if isinstance(data, list):
            if len(data) > 1 and all(isinstance(item, dict) for item in data[:3]):
                return True
        elif isinstance(data, dict):
            tabular_values = sum(1 for v in data.values() if isinstance(v, list) and len(v) > 1)
            if tabular_values > 0:
                return True
        
        return False
    
    def _format_toon(self, data: Any) -> str:
        """Format data as TOON with Droid metadata"""
        toon_data = self.encoder.encode(data)
        return f"// TOON format - 30-60% token reduction\n{toon_data}"
    
    def _format_json(self, data: Any) -> str:
        """Format data as JSON"""
        return self.json_encoder.encode(data)
    
    def parse_droid_response(self, response: str) -> Any:
        """
        Parse Droid's response, detecting TOON format
        
        Args:
            response: Response string from Droid
            
        Returns:
            Parsed data
        """
        if response.strip().startswith("// TOON format"):
            # Extract TOON data
            lines = response.split('\n')[1:]  # Skip comment line
            toon_str = '\n'.join(lines)
            return self.decoder.decode(toon_str)
        else:
            # Try JSON first
            try:
                return json.loads(response)
            except json.JSONDecodeError:
                # Return as string if parsing fails
                return response
    
    def optimize_tool_result(self, tool_name: str, result_data: Any) -> str:
        """
        Optimize tool result using TOON when beneficial
        
        Args:
            tool_name: Name of the tool that produced the result
            result_data: Raw tool result data
            
        Returns:
            Optimized result string
        """
        # Add metadata
        metadata = {
            "tool": tool_name,
            "optimization": "toon" if self._is_toon_suitable(result_data) else "json"
        }
        
        # Format result
        formatted_result = self.format_for_droid(result_data, "tool_result")
        
        # Combine metadata and result
        if self._should_use_toon(result_data, "tool_result"):
            return f"// Tool: {tool_name} | Format: TOON\n{formatted_result}"
        else:
            return formatted_result


# Example usage and testing
if __name__ == "__main__":
    # Sample data for testing
    sample_data = {
        "users": [
            {"id": 1, "name": "Alice", "role": "admin", "active": True},
            {"id": 2, "name": "Bob", "role": "user", "active": False},
            {"id": 3, "name": "Charlie", "role": "editor", "active": True}
        ],
        "total_count": 3
    }
    
    # Initialize TOON integration
    toon = Droid TOONIntegration()
    
    # Test encoding
    toon_result = toon.optimize_tool_result("list_users", sample_data)
    print("TOON Result:")
    print(toon_result)
    print()
    
    # Test decoding
    decoded = toon.parse_droid_response(toon_result)
    print("Decoded back to Python:")
    print(json.dumps(decoded, indent=2))
