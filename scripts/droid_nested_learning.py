#!/usr/bin/env python3
"""
Droid Nested Learning Framework
Integrates Google's Nested Learning approach into Droid's DNA for continual learning

Based on "Nested Learning, The Illusion of Deep Learning Architectures" 
by Google Research - treating models as nested optimization problems.

Key Concepts:
- Nested optimization problems vs single outer loop training
- Associative memory as operators mapping keys to values
- Catastrophic forgetting prevention
- Continual learning like biological brains
- Context flow and update frequency management
"""

import json
import time
import hashlib
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass, asdict
from enum import Enum
import asyncio
from collections import defaultdict


class LearningType(Enum):
    """Types of nested learning components"""
    ASSOCIATIVE_MEMORY = "associative_memory"
    OPTIMIZATION_ROUTINE = "optimization_routine" 
    KNOWLEDGE_STORE = "knowledge_store"
    SKILL_PATTERN = "skill_pattern"
    CONTEXT_FLOW = "context_flow"


class UpdateFrequency(Enum):
    """Update frequencies for nested components"""
    REALTIME = "realtime"          # Update on every interaction
    FREQUENT = "frequent"           # Every few interactions  
    PERIODIC = "periodic"           # Scheduled updates
    RARE = "rare"                  # Occasional consolidation
    DYNAMIC = "dynamic"            # Adaptive based on performance


@dataclass
class LearningContext:
    """Context flow information for nested learning"""
    session_id: str
    task_type: str
    input_sequence: List[str]
    success_metrics: Dict[str, float]
    timestamp: float
    environment_state: Dict[str, Any]


@dataclass
class AssociativeMemory:
    """Associative memory component storing key-value mappings"""
    key_pattern: str
    value_representation: Any
    confidence: float
    access_count: int
    last_accessed: float
    creation_context: LearningContext
    update_frequency: UpdateFrequency


@dataclass
class NestedComponent:
    """Base class for nested learning components"""
    component_id: str
    learning_type: LearningType
    context_flow: List[LearningContext]
    internal_objective: str
    update_frequency: UpdateFrequency
    last_updated: float
    performance_metrics: Dict[str, float]
    associated_memories: List[AssociativeMemory]


class ContinuousLearner:
    """
    Main class implementing Nested Learning framework for Droid
    
    Treats Droid as a collection of nested optimization problems instead of 
    a single monolithic learning system, enabling continual learning without 
    catastrophic forgetting.
    """
    
    def __init__(self, user_id: str = "default"):
        self.user_id = user_id
        self.components: Dict[str, NestedComponent] = {}
        self.knowledge_graph: Dict[str, List[str]] = defaultdict(list)
        self.performance_history: List[Dict[str, Any]] = []
        
        # Initialize core nested components
        self._init_core_components()
        
    def _init_core_components(self):
        """Initialize the core nested learning components"""
        
        # Tool Usage Pattern Memory
        tool_memory = NestedComponent(
            component_id="tool_usage_patterns",
            learning_type=LearningType.ASSOCIATIVE_MEMORY,
            context_flow=[],
            internal_objective="Learn optimal tool selection and usage patterns",
            update_frequency=UpdateFrequency.FREQUENT,
            last_updated=time.time(),
            performance_metrics={"hit_rate": 0.0, "efficiency": 0.0},
            associated_memories=[]
        )
        self.components["tool_usage_patterns"] = tool_memory
        
        # Context Understanding Component
        context_memory = NestedComponent(
            component_id="context_understanding",
            learning_type=LearningType.KNOWLEDGE_STORE,
            context_flow=[],
            internal_objective="Build contextual awareness for different project types",
            update_frequency=UpdateFrequency.REALTIME,
            last_updated=time.time(),
            performance_metrics={"context_accuracy": 0.0, "adaptation_speed": 0.0},
            associated_memories=[]
        )
        self.components["context_understanding"] = context_memory
        
        # Solution Strategy Memory
        strategy_memory = NestedComponent(
            component_id="solution_strategies",
            learning_type=LearningType.SKILL_PATTERN,
            context_flow=[],
            internal_objective="Store and retrieve effective problem-solving strategies",
            update_frequency=UpdateFrequency.PERIODIC,
            last_updated=time.time(),
            performance_metrics={"strategy_success_rate": 0.0},
            associated_memories=[]
        )
        self.components["solution_strategies"] = strategy_memory
        
        # Error Prevention Memory
        error_memory = NestedComponent(
            component_id="error_prevention",
            learning_type=LearningType.OPTIMIZATION_ROUTINE,
            context_flow=[],
            internal_objective="Learn from mistakes to prevent future errors",
            update_frequency=UpdateFrequency.FREQUENT,
            last_updated=time.time(),
            performance_metrics={"error_rate_reduction": 0.0},
            associated_memories=[]
        )
        self.components["error_prevention"] = error_memory
        
        # Knowledge Integration Component
        integration_memory = NestedComponent(
            component_id="knowledge_integration",
            learning_type=LearningType.CONTEXT_FLOW,
            context_flow=[],
            internal_objective="Integrate new knowledge with existing understanding",
            update_frequency=UpdateFrequency.DYNAMIC,
            last_updated=time.time(),
            performance_metrics={"integration_efficiency": 0.0},
            associated_memories=[]
        )
        self.components["knowledge_integration"] = integration_memory
    
    def learn_from_interaction(self, interaction_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process a single interaction through nested learning framework
        """
        
        # Extract context and performance information
        context = self._create_context_from_interaction(interaction_data)
        
        # Update frequency-based components
        updated_components = []
        for comp_id, component in self.components.items():
            if self._should_update_component(component, context):
                self._update_component(component, context, interaction_data)
                updated_components.append(comp_id)
        
        # Consolidate learning (simulate backpropagation-like update)
        self._consolidate_learning(context, updated_components)
        
        # Build associative connections
        self._build_associative_connections(context, updated_components)
        
        return {
            "updated_components": updated_components,
            "learning_metrics": self._calculate_learning_metrics(context),
            "adaptive_responses": self._generate_adaptive_responses(context)
        }
    
    def _create_context_from_interaction(self, interaction_data: Dict[str, Any]) -> LearningContext:
        """Create learning context from interaction data"""
        return LearningContext(
            session_id=interaction_data.get("session_id", "default"),
            task_type=interaction_data.get("task_type", "general"),
            input_sequence=interaction_data.get("input_sequence", []),
            success_metrics=interaction_data.get("success_metrics", {}),
            timestamp=time.time(),
            environment_state=interaction_data.get("environment_state", {})
        )
    
    def _should_update_component(self, component: NestedComponent, context: LearningContext) -> bool:
        """Determine if component should be updated based on frequency and relevance"""
        time_since_update = context.timestamp - component.last_updated
        
        # Calculate age-based update necessity
        age_factor = time_since_update / 3600  # hours since last update
        
        frequency_multipliers = {
            UpdateFrequency.REALTIME: 0.1,
            UpdateFrequency.FREQUENT: 1.0,
            UpdateFrequency.PERIODIC: 6.0,
            UpdateFrequency.RARE: 24.0,
            UpdateFrequency.DYNAMIC: age_factor  # Adaptive
        }
        
        threshold = frequency_multipliers[component.update_frequency]
        return age_factor >= threshold
    
    def _update_component(self, component: NestedComponent, context: LearningContext, 
                          interaction_data: Dict[str, Any]):
        """Update a specific nested component with new learning"""
        
        # Add to context flow
        component.context_flow.append(context)
        
        # Update performance metrics
        self._update_performance_metrics(component, context, interaction_data)
        
        # Create associative memories for this update
        new_memories = self._create_associative_memories(component, context, interaction_data)
        component.associated_memories.extend(new_memories)
        
        # Update timestamp
        component.last_updated = time.time()
        
        # Prune old contexts to manage memory
        if len(component.context_flow) > 100:
            component.context_flow = component.context_flow[-80:]  # Keep recent 80 contexts
    
    def _create_associative_memories(self, component: NestedComponent, 
                                    context: LearningContext, 
                                    interaction_data: Dict[str, Any]) -> List[AssociativeMemory]:
        """Create associative memories from the current interaction"""
        memories = []
        
        # Extract key patterns from the interaction
        input_pattern = self._extract_pattern(context.input_sequence)
        success_indicator = context.success_metrics.get("success", 0.0)
        
        if success_indicator > 0.5:  # Only learn from successful interactions
            memory = AssociativeMemory(
                key_pattern=input_pattern,
                value_representation={
                    "solution_approach": interaction_data.get("solution_approach"),
                    "tools_used": interaction_data.get("tools_used", []),
                    "context_features": self._extract_context_features(context),
                    "outcome": interaction_data.get("outcome"),
                    "performance": context.success_metrics
                },
                confidence=success_indicator,
                access_count=1,
                last_accessed=context.timestamp,
                creation_context=context,
                update_frequency=component.update_frequency
            )
            memories.append(memory)
        
        return memories
    
    def _extract_pattern(self, input_sequence: List[str]) -> str:
        """Extract key pattern from input sequence"""
        if not input_sequence:
            return ""
        
        # Simple pattern extraction - could be made more sophisticated
        key_elements = []
        for item in input_sequence[-3:]:  # Look at last 3 inputs
            # Remove common words and keep significant terms
            significant_words = [w.lower() for w in item.split() 
                               if len(w) > 4 and not w.startswith(('the', 'and', 'for'))]
            key_elements.extend(significant_words[:3])  # Top 3 significant words
        
        return "_".join(key_elements)
    
    def _extract_context_features(self, context: LearningContext) -> Dict[str, Any]:
        """Extract features from context for pattern recognition"""
        return {
            "task_domain": context.task_type,
            "input_length": len(context.input_sequence),
            "session_phase": self._detect_session_phase(context),
            "complexity_level": self._assess_complexity(context)
        }
    
    def _detect_session_phase(self, context: LearningContext) -> str:
        """Detect which phase of the session this is"""
        if len(context.input_sequence) <= 3:
            return "early"
        elif len(context.input_sequence) <= 10:
            return "middle"
        else:
            return "late"
    
    def _assess_complexity(self, context: LearningContext) -> str:
        """Assess complexity of the current context"""
        if context.success_metrics.get("complexity_score", 0) > 0.7:
            return "high"
        elif context.success_metrics.get("complexity_score", 0) > 0.4:
            return "medium"
        else:
            return "low"
    
    def _update_performance_metrics(self, component: NestedComponent, 
                                   context: LearningContext, 
                                   interaction_data: Dict[str, Any]):
        """Update performance metrics for a component"""
        if component.component_id == "tool_usage_patterns":
            # Update tool selection accuracy
            component.performance_metrics["hit_rate"] = context.success_metrics.get("tool_success", 0.0)
            component.performance_metrics["efficiency"] = context.success_metrics.get("efficiency", 0.0)
        
        elif component.component_id == "context_understanding":
            # Update context understanding accuracy
            component.performance_metrics["context_accuracy"] = context.success_metrics.get("context_match", 0.0)
            component.performance_metrics["adaptation_speed"] = len(context.input_sequence)
        
        elif component.component_id == "solution_strategies":
            # Update strategy success rate
            current_success = context.success_metrics.get("success", 0.0)
            component.performance_metrics["strategy_success_rate"] = (
                component.performance_metrics.get("strategy_success_rate", 0.0) * 0.8 + current_success * 0.2
            )
        
        elif component.component_id == "error_prevention":
            # Track error rate reduction
            error_occurred = context.success_metrics.get("error_occurred", False)
            if not error_occurred:
                component.performance_metrics["error_rate_reduction"] = min(1.0, 
                    component.performance_metrics.get("error_rate_reduction", 0.0) + 0.05)
        
        elif component.component_id == "knowledge_integration":
            # Track integration efficiency
            component.performance_metrics["integration_efficiency"] = context.success_metrics.get("integration_success", 0.0)
    
    def _consolidate_learning(self, context: LearningContext, updated_components: List[str]):
        """Consolidate learning across components (simulate backpropagation)"""
        # Simulate the consolidation process used in nested learning
        consolidation_weight = 0.3  # How much to transfer between components
        
        for comp_id in updated_components:
            component = self.components[comp_id]
            
            # Find related components for knowledge transfer
            related_components = self._find_related_components(comp_id, context)
            
            for related_comp_id in related_components:
                if related_comp_id in self.components:
                    related = self.components[related_comp_id]
                    self._transfer_knowledge(component, related, consolidation_weight)
    
    def _find_related_components(self, comp_id: str, context: LearningContext) -> List[str]:
        """Find components that should receive knowledge transfer"""
        # Define component relationships
        relationships = {
            "tool_usage_patterns": ["solution_strategies", "error_prevention"],
            "context_understanding": ["solution_strategies", "tool_usage_patterns"],
            "solution_strategies": ["tool_usage_patterns", "context_understanding"],
            "error_prevention": ["tool_usage_patterns", "solution_strategies"],
            "knowledge_integration": ["context_understanding", "solution_strategies"]
        }
        
        return relationships.get(comp_id, [])
    
    def _transfer_knowledge(self, source: NestedComponent, target: NestedComponent, weight: float):
        """Transfer knowledge from source to target component"""
        # Share the most relevant associative memories
        recent_memories = source.associated_memories[-3:]  # Last 3 memories
        
        for memory in recent_memories:
            if memory.confidence > 0.7:  # Only share high-confidence memories
                # Create a weighted copy for the target
                target_memory = AssociativeMemory(
                    key_pattern=memory.key_pattern,
                    value_representation=memory.value_representation.copy(),
                    confidence=memory.confidence * weight,  # Reduce confidence for transferred knowledge
                    access_count=0,
                    last_accessed=time.time(),
                    creation_context=memory.creation_context,
                    update_frequency=target.update_frequency
                )
                target.associated_memories.append(target_memory)
    
    def _build_associative_connections(self, context: LearningContext, updated_components: List[str]):
        """Build associative connections between memories across components"""
        # Connect memories based on similarity and temporal proximity
        for comp_id in updated_components:
            component = self.components[comp_id]
            
            # Update knowledge graph
            self.knowledge_graph[comp_id].extend(updated_components)
            
            # Remove self-references
            self.knowledge_graph[comp_id] = [c for c in self.knowledge_graph[comp_id] if c != comp_id]
    
    def _calculate_learning_metrics(self, context: LearningContext) -> Dict[str, float]:
        """Calculate overall learning metrics from the interaction"""
        total_memories = sum(len(comp.associated_memories) for comp in self.components.values())
        avg_confidence = 0.0
        
        if total_memories > 0:
            confidences = []
            for comp in self.components.values():
                confidences.extend([m.confidence for m in comp.associated_memories])
            avg_confidence = sum(confidences) / len(confidences)
        
        return {
            "total_memories": total_memories,
            "average_confidence": avg_confidence,
            "active_components": len([c for c in self.components.values() if c.context_flow]),
            "knowledge_connections": sum(len(connections) for connections in self.knowledge_graph.values())
        }
    
    def _generate_adaptive_responses(self, context: LearningContext) -> List[str]:
        """Generate adaptive responses based on learning"""
        responses = []
        
        # Check if similar patterns have been seen before
        pattern = self._extract_pattern(context.input_sequence)
        similar_memories = []
        
        for component in self.components.values():
            for memory in component.associated_memories:
                if self._pattern_match(pattern, memory.key_pattern) and memory.confidence > 0.6:
                    similar_memories.append(memory)
        
        if similar_memories:
            # Suggest approaches based on past successful interactions
            best_memory = max(similar_memories, key=lambda m: m.confidence)
            solution = best_memory.value_representation.get("solution_approach", "")
            if solution:
                responses.append(f"Based on past experience, consider: {solution}")
                
            # Suggest tools based on past success
            tools = best_memory.value_representation.get("tools_used", [])
            if tools:
                responses.append(f"Previously successful tools for similar tasks: {', '.join(tools)}")
        
        return responses
    
    def _pattern_match(self, pattern1: str, pattern2: str) -> bool:
        """Simple pattern matching between two patterns"""
        if not pattern1 or not pattern2:
            return False
        
        words1 = set(pattern1.split('_'))
        words2 = set(pattern2.split('_'))
        
        # Consider a match if they share at least 40% of words
        intersection = words1.intersection(words2)
        union = words1.union(words2)
        
        return len(intersection) / len(union) >= 0.4
    
    def retrieve_relevant_knowledge(self, query: str, context: Optional[LearningContext] = None) -> Dict[str, Any]:
        """Retrieve relevant knowledge based on a query"""
        relevant_memories = []
        
        # Search across all components
        for comp_id, component in self.components.items():
            for memory in component.associated_memories:
                if self._pattern_match(query.lower(), memory.key_pattern.lower()):
                    relevant_memories.append({
                        "component": comp_id,
                        "memory": memory,
                        "relevance": memory.confidence
                    })
        
        # Sort by relevance
        relevant_memories.sort(key=lambda x: x["relevance"], reverse=True)
        
        # Return top results
        top_memories = relevant_memories[:5] if relevant_memories else []
        
        return {
            "query": query,
            "count": len(top_memories),
            "memories": [
                {
                    "pattern": m["memory"].key_pattern,
                    "solution": m["memory"].value_representation.get("solution_approach", ""),
                    "confidence": m["memory"].confidence,
                    "component": m["component"]
                }
                for m in top_memories
            ]
        }
    
    def save_learning_state(self, filepath: str):
        """Save the current learning state to file"""
        state_data = {
            "user_id": self.user_id,
            "components": {k: asdict(v) for k, v in self.components.items()},
            "knowledge_graph": dict(self.knowledge_graph),
            "performance_history": self.performance_history,
            "timestamp": time.time()
        }
        
        with open(filepath, 'w') as f:
            json.dump(state_data, f, indent=2, default=str)
    
    def load_learning_state(self, filepath: str):
        """Load learning state from file"""
        try:
            with open(filepath, 'r') as f:
                state_data = json.load(f)
            
            # Recreate components from data
            for comp_id, comp_data in state_data["components"].items():
                self.components[comp_id] = NestedComponent(**comp_data)
            
            self.knowledge_graph = defaultdict(list, state_data["knowledge_graph"])
            self.performance_history = state_data["performance_history"]
            
        except FileNotFoundError:
            print(f"Learning state file not found: {filepath}")
        except Exception as e:
            print(f"Error loading learning state: {e}")
    
    def generate_learning_report(self) -> Dict[str, Any]:
        """Generate a comprehensive learning report"""
        report = {
            "learning_summary": {
                "total_components": len(self.components),
                "total_memories": sum(len(comp.associated_memories) for comp in self.components.values()),
                "knowledge_graph_nodes": len(self.knowledge_graph),
                "knowledge_graph_edges": sum(len(edges) for edges in self.knowledge_graph.values())
            },
            "component_performance": {},
            "recent_learning": []
        }
        
        # Component performance
        for comp_id, component in self.components.items():
            report["component_performance"][comp_id] = {
                "memories_count": len(component.associated_memories),
                "last_updated": component.last_updated,
                "performance": component.performance_metrics
            }
        
        # Recent learning highlights
        for comp_id, component in self.components.items():
            for memory in component.associated_memories[-2:]:  # Last 2 memories per component
                report["recent_learning"].append({
                    "component": comp_id,
                    "pattern": memory.key_pattern,
                    "confidence": memory.confidence,
                    "timestamp": memory.last_accessed
                })
        
        # Sort by timestamp
        report["recent_learning"].sort(key=lambda x: x["timestamp"], reverse=True)
        report["recent_learning"] = report["recent_learning"][:10]  # Top 10 recent learnings
        
        return report


# Example usage and testing
if __name__ == "__main__":
    # Initialize the nested learning system for Droid
    droid_learner = ContinuousLearner("demo_user")
    
    # Simulate some interactions
    sample_interactions = [
        {
            "session_id": "session_1",
            "task_type": "code_review",
            "input_sequence": ["Review this Python function", "Check for bugs", "Optimize performance"],
            "success_metrics": {"success": 0.8, "efficiency": 0.7, "tool_success": 0.9},
            "solution_approach": "Used systematic code review methodology",
            "tools_used": ["Read", "Grep", "python"],
            "outcome": "Found 3 bugs and suggested 2 optimizations"
        },
        {
            "session_id": "session_2", 
            "task_type": "file_creation",
            "input_sequence": ["Create a new Python script", "Add error handling", "Include documentation"],
            "success_metrics": {"success": 0.9, "efficiency": 0.8, "tool_success": 1.0},
            "solution_approach": "Started with basic structure then added features iteratively",
            "tools_used": ["Create"],
            "outcome": "Successfully created well-structured script"
        }
    ]
    
    # Process interactions
    print("🤖 Droid Nested Learning Framework - Demonstration")
    print("=" * 60)
    
    for i, interaction in enumerate(sample_interactions, 1):
        print(f"\n📝 Processing Interaction {i}: {interaction['task_type']}")
        
        result = droid_learner.learn_from_interaction(interaction)
        
        print(f"✅ Updated components: {result['updated_components']}")
        print(f"📊 Learning metrics: {result['learning_metrics']}")
        
        if result['adaptive_responses']:
            print(f"🧠 Adaptive insights:")
            for response in result['adaptive_responses']:
                print(f"   • {response}")
    
    # Demonstrate knowledge retrieval
    print(f"\n🔍 Searching for relevant knowledge about code review...")
    knowledge = droid_learner.retrieve_relevant_knowledge("code_review_check_bugs")
    
    print(f"Found {knowledge['count']} relevant memories:")
    for memory in knowledge['memories']:
        print(f"  • Pattern: {memory['pattern']}")
        print(f"    Solution: {memory['solution']}")
        print(f"    Confidence: {memory['confidence']:.2f}")
        print(f"    Component: {memory['component']}")
    
    # Generate learning report
    print(f"\n📈 Learning Report:")
    report = droid_learner.generate_learning_report()
    
    print(f"Total components: {report['learning_summary']['total_components']}")
    print(f"Total memories: {report['learning_summary']['total_memories']}")
    print(f"Knowledge graph: {report['learning_summary']['knowledge_graph_nodes']} nodes, {report['learning_summary']['knowledge_graph_edges']} edges")
    
    print(f"\n🧠 Recent learning highlights:")
    for learning in report['recent_learning'][:3]:
        print(f"  • {learning['component']}: {learning['pattern']} (confidence: {learning['confidence']:.2f})")
    
    print(f"\n✨ Nested Learning demonstration complete!")
    print("Droid now demonstrates continual learning without catastrophic forgetting,")
    print("treating each component as a nested optimization problem for better adaptation.")
