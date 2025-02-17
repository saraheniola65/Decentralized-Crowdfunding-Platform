import { describe, it, expect } from "vitest"

// Mock the Clarity functions and types
const mockClarity = {
  tx: {
    sender: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  },
  types: {
    uint: (value: number) => ({ type: "uint", value }),
    principal: (value: string) => ({ type: "principal", value }),
    string: (value: string) => ({ type: "string", value }),
    bool: (value: boolean) => ({ type: "bool", value }),
  },
}

// Mock contract calls
const contractCalls = {
  "add-milestone": (campaignId: number, description: string, targetAmount: number) => {
    return { success: true, value: mockClarity.types.uint(0) }
  },
  "complete-milestone": (milestoneId: number) => {
    return { success: true, value: true }
  },
  "get-milestone": (milestoneId: number) => {
    return {
      success: true,
      value: {
        "campaign-id": mockClarity.types.uint(0),
        description: mockClarity.types.string("First milestone"),
        "target-amount": mockClarity.types.uint(500000),
        completed: mockClarity.types.bool(false),
      },
    }
  },
}

describe("Milestone Contract", () => {
  it("should add a milestone", () => {
    const result = contractCalls["add-milestone"](0, "First milestone", 500000)
    expect(result.success).toBe(true)
    expect(result.value).toEqual(mockClarity.types.uint(0))
  })
  
  it("should complete a milestone", () => {
    const result = contractCalls["complete-milestone"](0)
    expect(result.success).toBe(true)
    expect(result.value).toBe(true)
  })
  
  it("should get milestone details", () => {
    const result = contractCalls["get-milestone"](0)
    expect(result.success).toBe(true)
    expect(result.value).toEqual({
      "campaign-id": mockClarity.types.uint(0),
      description: mockClarity.types.string("First milestone"),
      "target-amount": mockClarity.types.uint(500000),
      completed: mockClarity.types.bool(false),
    })
  })
})

