defmodule BooleanLogic.Or do
    @moduledoc """
    Neural network training of a Boolean logic Or.
    """

    # Constants
    @rate 0.2  # Weight adjustment rate.
    @threshold 98 # Threshold required for neuron to fire.
    @epoch_max 10  # For limiting the number of iterations, eg while experimenting.


    def main() do
        weights = init_weights(2)
        training_set = get_training_data()
        
        epoch_state = %{id: 0, epoch_results: [], epoch_success: 0}
        run_training(training_set, weights, epoch_state)
    end

    #def run_training(epoch_max, _training_set, weights, %{id: id, epoch_results: epoch_results, epoch_success: epoch_success}) when id >= epoch_max do
    def run_training(training_set, weights, epoch_state) do
        if epoch_state[:id] >= @epoch_max || epoch_state[:epoch_success] >= @threshold do
            {weights, epoch_state}
        else
            {weights, epoch_state} = run_epoch(training_set, weights, epoch_state)
            run_training(training_set, weights, epoch_state)
        end
    end

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

    def run_tests(test, {weights, epoch_results}) do
        display_test_header(weights)

        test_inputs = test_get_inputs(test)
        test_answer = test_get_answer(test)
        
        neuron_output = neuron_activation_function(test_inputs, weights)
        is_activated = is_output_correct(test_answer, neuron_output)
        if is_activated == false do
            # We build a function to avoid having to pass the same values repeatedly.
            weight_updater = get_weight_updater(test_answer, neuron_output, @rate)
            weights = Enum.reduce([0, 1], weights, fn(input_idx, weights) ->
                weight_updater.(input_idx, weights)
            end)
        end
        
        epoch_results = save_test_result(epoch_results, is_activated)
        display_test_footer(test_inputs, neuron_output, is_activated)
        {weights, epoch_results}
    end
    
    # This is an example of partial function application.
    def get_weight_updater(test_answer, neuron_output, rate) do
        fn(input_idx, weights) -> 
            new_weight = Enum.at(weights, input_idx) + (rate * (test_answer - neuron_output))
            List.replace_at(weights, input_idx, new_weight)
        end
    end

    def neuron_activation_function(inputs, weights) do  # Perceptron
        sum = Enum.at(inputs, 0) * Enum.at(weights, 0) + Enum.at(inputs, 1) * Enum.at(weights, 1)
        threshold = 2
        if (sum > threshold) do
            1.0
        else
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
        << a :: 32, b :: 32, c :: 32 >> = :crypto.rand_bytes(12)
        :random.seed(a, b, c)
        Float.round(:random.uniform, 2)
    end

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
