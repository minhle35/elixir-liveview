defmodule SuperCalculator.CalculationsTest do
  use SuperCalculator.DataCase, async: true

  alias SuperCalculator.Calculations

  describe "compute_super/1" do
    test "calculates 11.5% of salary" do
      {:ok, result} = Calculations.compute_super("100000")
      assert Decimal.equal?(result, Decimal.new("11500.0"))
    end

    test "returns error for non-numeric input" do
      assert {:error, :invalid} = Calculations.compute_super("abc")
    end

    test "returns error for empty string" do
      assert {:error, :invalid} = Calculations.compute_super("")
    end
  end

  describe "save_calculation/1" do
    test "saves a valid calculation to the database" do
      assert {:ok, calc} = Calculations.save_calculation("80000")
      assert Decimal.equal?(calc.salary, Decimal.new("80000"))
      assert Decimal.equal?(calc.super_contribution, Decimal.new("9200.0"))
    end

    test "returns error for invalid input" do
      assert {:error, :invalid} = Calculations.save_calculation("bad")
    end
  end

  describe "list_calculations/0" do
    test "returns saved calculations" do
      Calculations.save_calculation("50000")
      Calculations.save_calculation("100000")

      results = Calculations.list_calculations()
      salaries = Enum.map(results, & &1.salary) |> Enum.map(&Decimal.to_string/1)
      assert "50000" in salaries
      assert "100000" in salaries
    end
  end
end
