<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <a-col :span="24">
            <a-form-model-item label="統計時間" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="usageDate">
              <j-date placeholder="請選擇統計時間" v-model="model.usageDate"  style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="內存用量" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="ram">
              <a-input-number v-model="model.ram" placeholder="請輸入內存用量" style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="週期內CPU-小時數" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="totalVcpusUsage">
              <a-input-number v-model="model.totalVcpusUsage" placeholder="請輸入週期內CPU-小時數" style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="週期內磁盤GB-小時數" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="totalLocalGbUsage">
              <a-input-number v-model="model.totalLocalGbUsage" placeholder="請輸入週期內磁盤GB-小時數" style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="週期內的 RAM-小時數" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="totalMemoryMbUsage">
              <a-input-number v-model="model.totalMemoryMbUsage" placeholder="請輸入週期內的 RAM-小時數" style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="總運行時長" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="totalHours">
              <a-input v-model="model.totalHours" placeholder="請輸入總運行時長"  ></a-input>
            </a-form-model-item>
          </a-col>
        </a-row>
      </a-form-model>
    </j-form-container>
  </a-spin>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
  import { validateDuplicateValue } from '@/utils/util'

  export default {
    name: 'OsResourceUsageForm',
    components: {
    },
    props: {
      //表單禁用
      disabled: {
        type: Boolean,
        default: false,
        required: false
      }
    },
    data () {
      return {
        model:{
         },
        labelCol: {
          xs: { span: 24 },
          sm: { span: 5 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        validatorRules: {
           usageDate: [
              { required: true, message: '請輸入統計時間!'},
           ],
           ram: [
              { required: true, message: '請輸入內存用量!'},
           ],
           totalVcpusUsage: [
              { required: true, message: '請輸入週期內CPU-小時數!'},
           ],
           totalLocalGbUsage: [
              { required: true, message: '請輸入週期內磁盤GB-小時數!'},
           ],
           totalMemoryMbUsage: [
              { required: true, message: '請輸入週期內的 RAM-小時數!'},
           ],
        },
        url: {
          add: "/openstack/osResourceUsage/add",
          edit: "/openstack/osResourceUsage/edit",
          queryById: "/openstack/osResourceUsage/queryById"
        }
      }
    },
    computed: {
      formDisabled(){
        return this.disabled
      },
    },
    created () {
       //備份model原始值
      this.modelDefault = JSON.parse(JSON.stringify(this.model));
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
      },
      submitForm () {
        const that = this;
        // 觸發表單驗證
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            let httpurl = '';
            let method = '';
            if(!this.model.id){
              httpurl+=this.url.add;
              method = 'post';
            }else{
              httpurl+=this.url.edit;
               method = 'put';
            }
            httpAction(httpurl,this.model,method).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
            })
          }
         
        })
      },
    }
  }
</script>