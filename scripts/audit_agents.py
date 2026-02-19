import yaml
import os
import sys


def audit_agents(root_dir):
    agents_dir = os.path.join(root_dir, "agents")
    print(f"Auditing Agents in {agents_dir}")

    agent_files = []
    for root, dirs, files in os.walk(agents_dir):
        for file in files:
            if file.endswith(".yaml") or file.endswith(".yml"):
                # Heuristic: agent files usually start with agent_ or are in a specific structure
                # We'll check all yaml files but check if they look like agents
                path = os.path.join(root, file)
                agent_files.append(path)

    issues = []

    for agent_path in agent_files:
        try:
            with open(agent_path, "r") as f:
                content = yaml.safe_load(f)

            # Basic validation: must have specific fields to be an agent
            if not content or not isinstance(content, dict):
                continue

            # Check if it's actually an agent definition
            if "instructions" not in content and "model" not in content:
                # Likely not an agent file (maybe a config or test)
                # However, KODA agents might be defined differently.
                # Let's check for _manifest or safety_constraints_and_behavioral_guardrails
                if "_manifest" not in content:
                    continue

            rel_path = os.path.relpath(agent_path, root_dir)
            print(f"Checking {rel_path}...")

            # Check Security Guards
            warnings = []
            if "safety_constraints_and_behavioral_guardrails" in content:
                guards = content["safety_constraints_and_behavioral_guardrails"]
                if not guards.get("block_instructions"):
                    warnings.append("Missing or false 'block_instructions'")
                if not guards.get("forbid_internal_jargon"):
                    warnings.append("Missing or false 'forbid_internal_jargon'")
            else:
                warnings.append(
                    "Missing 'safety_constraints_and_behavioral_guardrails' block"
                )

            # Check Manifest
            if "_manifest" not in content:
                warnings.append("Missing '_manifest' block")

            # Check Runtime Instructions
            # Some agents might use different keys, but KODA standard seems to be 'KODA_Runtime_Instructions' or similar in comments?
            # actually looking at the checklists: "Has KODA_Runtime_Instructions block"
            # It might be a top level key or part of instructions.
            # I'll check for the KEY `KODA_Runtime_Instructions`
            if "KODA_Runtime_Instructions" not in content:
                # formatting might be different, strict check
                warnings.append("Missing 'KODA_Runtime_Instructions' key")

            if warnings:
                issues.append({"file": rel_path, "warnings": warnings})

        except Exception as e:
            print(f"Error reading {agent_path}: {e}")

    print("\n--- AGENT AUDIT RESULTS ---")
    if issues:
        print(f"\n[ISSUES FOUND] ({len(issues)} agents)")
        for issue in issues:
            print(f"  File: {issue['file']}")
            for warning in issue["warnings"]:
                print(f"    - {warning}")
    else:
        print("\n[OK] All agents passed security and structure checks.")


if __name__ == "__main__":
    audit_agents("/Users/felixsanhueza/Developer/koda")
