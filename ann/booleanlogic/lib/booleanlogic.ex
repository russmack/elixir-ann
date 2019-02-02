defmodule BooleanLogic.Or do

    @moduledoc """
    Artificial neural network training of a Boolean logic Or.
    """

  
    # Constants
    @rate 0.2       # Weight adjustment rate.
    @threshold 98   # Threshold required for neuron to fire.
    @epoch_max 10   # For limiting the number of iterations, eg while experimenting.
    @bias 1


    def main() do
        weights = init_weights(2)
        IO.puts ""
        IO.puts "--------- Initial State ----------"
        IO.puts "Weights: #{inspect weights}"
        IO.puts "----------------------------------"
        training_set = get_training_data()
        IO.puts "Training set: #{inspect training_set}"
        IO.puts "----------------------------------"
        
        epoch_state = %{id: 0, epoch_results: [], epoch_success: 0}
        run_training(training_set, weights, epoch_state)
        IO.puts "Done."
    end


    @doc """
    Run as many epochs as required for success, or limited by max.
    """
    def run_training(training_set, weights, epoch_state) do
        if epoch_state[:id] >= @epoch_max || epoch_state[:epoch_success] >= @threshold do
            {weights, epoch_state}
        else
            {weights, epoch_state} = run_epoch(training_set, weights, epoch_state)
            run_training(training_set, weights, epoch_state)
        end
    end


    @doc """
    Run tests, check results, return updated weights and epoch results.
    """
    def run_epoch(training_set, weights, epoch_state) do
        epoch_id = epoch_state[:id] + 1
        display_epoch_header(epoch_id)
        epoch_results = epoch_state[:epoch_results]

        {weights, epoch_results} = Enum.reduce(training_set, {weights, epoch_results}, fn(test, {weights, epoch_results}) -> 
            run_tests(test, {weights, epoch_results})
        end)
        
        epoch_success = (Enum.sum(epoch_results) / Enum.count(epoch_results)) * 100
        
        display_epoch_footer(epoch_id, epoch_success)
        epoch_state = %{id: epoch_id, epoch_results: [], epoch_success: epoch_success}  # Clear epoch results.
        {weights, epoch_state}
    end


    @doc """
    Run the tests, update the weights according to results.
    """
    def run_tests(test, {weights, epoch_results}) do
        display_test_header(weights)

        test_inputs = test_get_inputs(test)
        test_answer = test_get_answer(test)
        
        neuron_output = neuron_activation_function(test_inputs, weights)
        IO.puts "Neuron output: #{neuron_output}"
        is_activated = is_output_correct(test_answer, neuron_output)
        IO.puts "Activated: #{is_activated}"
        weights = if is_activated == false do
            # We build a function having some fixed values.
            weight_updater = get_weight_updater(test_answer, neuron_output, @rate)
            IO.puts "Weights adjusted from: #{inspect weights}"
            weights = Enum.reduce([0, 1], weights, fn(input_idx, weights) ->
                weight_updater.(input_idx, weights)
            end)
            IO.puts "Weights adjusted to: #{inspect weights}"
            weights
        else
            weights
        end
        
        epoch_results = save_test_result(epoch_results, is_activated)
        display_test_footer(test_inputs, neuron_output, is_activated)
        {weights, epoch_results}
    end


    @doc """
    A partial function, uses a closure, returns a function with fixed initial values.
    """
    def get_weight_updater(test_answer, neuron_output, rate) do
        fn(input_idx, weights) -> 
            new_weight = Enum.at(weights, input_idx) + (rate * (test_answer - neuron_output))
            List.replace_at(weights, input_idx, new_weight)
        end
    end


    @doc """
    Perceptron, determines if input values and weights are sufficient to jump the synaptic gap.
    """
    def neuron_activation_function(inputs, weights) do
        sum = @bias + Enum.at(inputs, 0) * Enum.at(weights, 0) + Enum.at(inputs, 1) * Enum.at(weights, 1)
        threshold = 2.0
        IO.puts "Activation fn sum: #{sum}"
        if (sum > threshold) do
            IO.puts "Sum is above threshold"
            1.0
        else
            IO.puts "Sum is below threshold"
            0.0
        end
    end


    def is_output_correct(test_answer, neuron_output) do
        if test_answer == neuron_output do
            true
        else
            false
        end
    end


    def test_get_answer(test) do
        List.first tl test
    end


    def test_get_inputs(test) do
        hd test
    end


    def random() do
        << a :: 32, b :: 32, c :: 32 >> = :crypto.strong_rand_bytes(12)
        :random.seed(a, b, c)
        Float.round(:random.uniform, 2)
    end


    @doc """
    Initialize weights.
    """
    def init_weights(max), do: fill_weights(max, 0, [])
    def fill_weights(max, counter, weights) when counter >= max, do: weights
    def fill_weights(max, counter, weights) do
            size = length(weights)
            rnd_weight = random()
            weights = List.insert_at(weights, size, rnd_weight)
            fill_weights(max, counter+1, weights)
    end


    def get_training_data() do
        [
            [ [ 0.0, 0.0 ], 0.0 ], 
            [ [ 0.0, 1.0 ], 1.0 ], 
            [ [ 1.0, 0.0 ], 1.0 ], 
            [ [ 1.0, 1.0 ], 1.0 ]
        ]
    end


    def save_test_result(epoch_results, is_activated) do
        activated = if is_activated, do: 1, else: 0
        List.insert_at(epoch_results, Enum.count(epoch_results), activated)
    end


    def display_epoch_header(epoch_id) do
        IO.puts ""
        IO.puts "##### Epoch #{epoch_id} #####"
        IO.puts "-----------------------------------------------"
    end


    def display_epoch_footer(epoch_id, epoch_success) do
        IO.puts "##### Epoch #{inspect epoch_id} : #{inspect epoch_success} #####"
        IO.puts "-----------------------------------------------"
    end


    def display_test_header(weights) do
        IO.puts "Weights: #{inspect weights}"
    end


    def display_test_footer(test_inputs, neuron_output, is_activated) do
        inputs_csv = Enum.join(test_inputs, ", ")
        IO.puts " #{inputs_csv} gave #{inspect neuron_output} : #{inspect is_activated}"
        IO.puts "-----------------------------------------------"
    end
end
